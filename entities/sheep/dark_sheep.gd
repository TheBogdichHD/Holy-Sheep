class_name DarkSheep
extends CharacterBody3D

@export var sheep_distance_run = 0
@export var walking_speed = 0.0
@export var running_speed = 0.0
@export var sheep_color: Color = Color(0, 0, 0)

var sounds: Array = [
	preload("res://audio/sheeps/black_sheep1.mp3"),
	preload("res://audio/sheeps/black_sheep2.mp3"),
	preload("res://audio/sheeps/black_sheep3.mp3")
]

var _destination = Vector3.ZERO
var _is_walking = false
var _is_running_away = false
var _vertical_velocity: float = 0.0

@onready var audiosource: AudioStreamPlayer3D = $AudioStreamPlayer3D
@onready var player_location = global_position
@onready var timer: Timer = $Timer
@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D
@onready var sheep_model: Node3D = %SheepModel
@onready var lifetimer: Timer = $LifeTimer


func _ready() -> void:
	print("Dark sheep spawned...")
	lifetimer.wait_time = randi_range(5, 20)
	lifetimer.start()
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
	if _screaming and _player != null:
		scream(_player)
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
	await get_tree().create_timer(0.4).timeout
	player_location = target_location
	var distance = global_transform.origin.distance_to(target_location)
	var new_position = global_transform.origin
	
	if distance * 2 >= sheep_distance_run:
		var dir_to_player = target_location - global_transform.origin
		
		new_position = target_location
		_is_walking = false
		_is_running_away = true
	else:
		_is_running_away = false
		if _destination.distance_to(global_transform.origin) < 0.05 and not _is_walking:
			_is_walking = true
			timer.wait_time = randi_range(4, 7)
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
	velocity = velocity.move_toward(safe_velocity, 0.0001)
	velocity += Vector3(0, _vertical_velocity * 0.4, 0)
	
	var _direction = player_location - global_position
	var target_rotation_y = atan2(-_direction.x, -_direction.z) + deg_to_rad(90)
	rotation.y = lerp_angle(rotation.y, target_rotation_y, 0.1)
	
	move_and_slide()
# HACK: very bad, i dont know how to do better
func enable_outline():
	var cube: MeshInstance3D = sheep_model.get_child(0)
	var surface_material: StandardMaterial3D = cube.mesh.surface_get_material(0)
	var dup_surface_material = surface_material.duplicate(true)
	
	var shader: ShaderMaterial = surface_material.next_pass
	var dup_shader = shader.duplicate(true)
	
	dup_shader.set_shader_parameter("size", 1.05)
	dup_shader.set_shader_parameter("color", sheep_color)
	
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


var _player

func _on_area_3d_area_entered(area: Area3D) -> void:
	if area.is_in_group("player"):
		enable_outline()


func _on_area_3d_area_exited(area: Area3D) -> void:
	if area.is_in_group("player"):
		disable_outline()

var _screaming = false
func scream(player):
	var direction = player_location - global_transform.origin
	direction.y *= 0.2
	direction.x *= 3
	direction.z *= 3
	player.additional_velocity = direction


func _on_scream_range_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		_player = body
		await get_tree().create_timer(randf_range(0, 0.4)).timeout
		_screaming = true



func _on_scream_range_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		_screaming = false
		_player.additional_velocity = Vector3.ZERO
		_player = null


func _on_rotation_timer_timeout() -> void:
	pass
	'''var direction = player_location - global_position 
	var target_rotation_y = atan2(-direction.x, -direction.z) + deg_to_rad(90)
	rotation.y = lerp_angle(rotation.y, target_rotation_y, 0.5)
	move_and_slide()'''


func _on_life_timer_timeout() -> void:
	print("Dark sheep disappeared...")
	queue_free()


func _on_visible_on_screen_notifier_3d_screen_entered() -> void:
	audiosource.stream = sounds[randi() % 3]
	audiosource.play()
