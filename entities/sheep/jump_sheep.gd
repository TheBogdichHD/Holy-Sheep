class_name JumpSheep
extends CharacterBody3D

@export var sheep_distance_run = 10
@export var walking_speed = 5.0
@export var running_speed = 20.0
@export var jump_height = 1
@export var sheep_color = Color(0, 1, 0)
@export var max_distance = 50

var sounds: Array = [
	preload("res://audio/sheeps/green_sheep1.mp3"),
	preload("res://audio/sheeps/green_sheep2.mp3"),
	preload("res://audio/sheeps/green_sheep3.mp3")
]

var _destination = Vector3.ZERO
var _is_walking = false
var _is_running_away = false
var _vertical_velocity: float = 0.0
var _is_falling = false

@onready var bee_timer: Timer = $BeeTimer
@onready var audiosource: AudioStreamPlayer3D = $AudioStreamPlayer3D
@onready var timer: Timer = $Timer
@onready var navigation_agent_3d: NavigationAgent3D = %JumpSheepAgent
@onready var sheep_model: Node3D = $SheepModel


func _ready() -> void:
	audiosource.volume_db = 50
	var cube: MeshInstance3D = sheep_model.get_child(0)
	var surface_material: StandardMaterial3D = cube.mesh.surface_get_material(0)
	var dup_surface_material = surface_material.duplicate(true)

	dup_surface_material.albedo_color = sheep_color

	cube.set_surface_override_material(0, dup_surface_material)

	navigation_agent_3d.target_position = global_transform.origin
	set_physics_process(false)
	call_deferred("dump_first_physics_frame")


func dump_first_physics_frame() -> void:
	await get_tree().physics_frame
	set_physics_process(true)


func _physics_process(delta: float) -> void:
	var current_location = global_transform.origin
	var next_location = navigation_agent_3d.get_next_path_position()
	var new_velocity
	if _is_running_away:
		new_velocity = (next_location - current_location).normalized() * running_speed
	else:
		new_velocity = (next_location - current_location).normalized() * walking_speed
	if not is_on_floor():
		_vertical_velocity += get_gravity().y * delta
	else:
		_vertical_velocity = 0
	navigation_agent_3d.set_velocity_forced(new_velocity)


func update_target_location(target_location) -> void:
	var distance = (global_transform.origin - Vector3(0, global_transform.origin.y, 0)).distance_to(target_location - Vector3(0, target_location.y, 0))
	var new_position = global_transform.origin
	if distance > max_distance:
		return
	if distance < sheep_distance_run:
		var dir_to_player = global_transform.origin - target_location
		new_position = global_transform.origin + Vector3(dir_to_player.x, 0, dir_to_player.z)
		_is_walking = false
		_is_running_away = true
		sheep_model.set_speed(2)
	else:
		_is_running_away = false
		if _destination.distance_to(global_transform.origin) < 0.05 and not _is_walking:
			sheep_model.set_speed(1)
			_is_walking = true
			timer.wait_time = randi_range(3, 5)
			timer.start()
		else:
			new_position = _destination
	navigation_agent_3d.target_position = new_position


func _on_timer_timeout() -> void:
	_destination = Vector3(
			global_transform.origin.x + randi_range(-50, 50),
			global_transform.origin.y,
			global_transform.origin.z + randi_range(-50, 50))
	_is_walking = true


func _on_navigation_agent_3d_velocity_computed(safe_velocity: Vector3) -> void:
	velocity = velocity.move_toward(safe_velocity, 0.3)
	if _is_running_away and is_on_floor():
		sheep_model.jump()
		audiosource.stream = sounds[randi() % 3]
		audiosource.play()
		await get_tree().create_timer(.5).timeout
		_vertical_velocity = sqrt(2 * -get_gravity().y * jump_height)
		velocity.y = _vertical_velocity
	elif not is_on_floor():
		velocity.y = _vertical_velocity
		if not _is_falling:
			sheep_model.fall()
			_is_falling = true
	if is_on_floor():
		sheep_model.stop()
		_is_falling = false
	if velocity.length() > 0.1:
		var target_rotation_y = atan2(-velocity.x, -velocity.z) + deg_to_rad(90)
		rotation.y = lerp_angle(rotation.y, target_rotation_y, 0.1)
		if is_on_floor():
			sheep_model.stop()
	move_and_slide()

# HACK: very bad, i dont know how to do better
func enable_outline():
	var cube: MeshInstance3D = sheep_model.get_child(0)
	var surface_material: StandardMaterial3D = cube.mesh.surface_get_material(0)
	var dup_surface_material = surface_material.duplicate(true)

	var shader: ShaderMaterial = surface_material.next_pass
	var dup_shader = shader.duplicate(true)

	dup_shader.set_shader_parameter("color", sheep_color)
	dup_shader.set_shader_parameter("size", 1.05)

	dup_surface_material.albedo_color = sheep_color
	dup_surface_material.next_pass = dup_shader
	cube.set_surface_override_material(0, dup_surface_material)



func disable_outline():
	var cube: MeshInstance3D = sheep_model.get_child(0)
	var surface_material: StandardMaterial3D = cube.mesh.surface_get_material(0)
	var dup_surface_material = surface_material.duplicate(true)

	var shader: ShaderMaterial = surface_material.next_pass
	var dup_shader = shader.duplicate(true)

	dup_shader.set_shader_parameter("size", 1.0)

	dup_surface_material.albedo_color = sheep_color
	dup_surface_material.next_pass = dup_shader
	cube.set_surface_override_material(0, dup_surface_material)

func _on_area_3d_area_entered(area: Area3D) -> void:
	if area.is_in_group("player"):
		enable_outline()


func _on_area_3d_area_exited(area: Area3D) -> void:
	if area.is_in_group("player"):
		disable_outline()
