class_name SheepFromBox
extends CharacterBody3D


@export var sheep_distance_run = 15
@export var walking_speed = 5.0
@export var running_speed = 10.0
@export var sheep_color = Color(0, 0, 0)
var _destination = Vector3.ZERO
var _is_walking = false
var _is_running_away = false
var _vertical_velocity: float = 0.0

@onready var timer: Timer = $Timer
@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D
@onready var sheep_model: Node3D = %SheepModel


func _ready() -> void:
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
	var distance = global_transform.origin.distance_to(target_location)
	var new_position = global_transform.origin
	
	if distance < sheep_distance_run:
		var dir_to_player = global_transform.origin - target_location
		
		new_position = global_transform.origin + Vector3(dir_to_player.x, 0, dir_to_player.z)
		_is_walking = false
		_is_running_away = true
	else:
		_is_running_away = false
		if _destination.distance_to(global_transform.origin) < 0.05 and not _is_walking:
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
	velocity += Vector3(0, _vertical_velocity * 0.4, 0)
	
	if velocity.length() > 0.1:
		var target_rotation_y = atan2(-velocity.x, -velocity.z) + deg_to_rad(90)
		
		rotation.y = lerp_angle(rotation.y, target_rotation_y, 0.1)
	
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
