class_name JumpSheep
extends CharacterBody3D


@export var sheep_distance_run = 10
@export var walking_speed = 5.0
@export var running_speed = 20.0
@export var jump_height = 7

var _destination = Vector3.ZERO
var _is_walking = false
var _is_running_away = false
var _vertical_velocity: float = 0.0

@onready var timer: Timer = $Timer
@onready var navigation_agent_3d: NavigationAgent3D = %JumpSheepAgent


func _ready() -> void:
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
	if distance < sheep_distance_run:
		var dir_to_player = global_transform.origin - target_location
		new_position = global_transform.origin + Vector3(dir_to_player.x, 0, dir_to_player.z)
		_is_walking = false
		_is_running_away = true
	else:
		_is_running_away = false
		if _destination.distance_to(global_transform.origin) < 0.05 and not _is_walking:
			_is_walking = false
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
		_vertical_velocity = sqrt(2 * -get_gravity().y * jump_height)
		velocity.y = _vertical_velocity
	elif not is_on_floor():
		velocity.y = _vertical_velocity
	if velocity.length() > 0.1:
		var target_rotation_y = atan2(-velocity.x, -velocity.z) + deg_to_rad(90)
		rotation.y = lerp_angle(rotation.y, target_rotation_y, 0.1)
	move_and_slide()