class_name Sheep
extends CharacterBody3D


@export var sheep_distance_run = 10
@export var walking_speed = 5.0
@export var running_speed = 15.0

var _destination = Vector3.ZERO
var _is_walking = false
var _is_running_away = false

@onready var timer: Timer = $Timer
@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D


func _ready() -> void:
	navigation_agent_3d.target_position = global_transform.origin
	set_physics_process(false)
	call_deferred("dump_first_physics_frame")


func dump_first_physics_frame() -> void:
	await get_tree().physics_frame
	set_physics_process(true)


func _physics_process(_delta: float) -> void:
	var current_location = global_transform.origin
	var next_location = navigation_agent_3d.get_next_path_position()
	var new_velocity
	if _is_running_away:
		new_velocity = (next_location - current_location).normalized() * running_speed
	else:
		new_velocity = (next_location - current_location).normalized() * walking_speed
		
	navigation_agent_3d.set_velocity_forced(new_velocity)


func update_target_location(target_location) -> void:
	var distance = global_transform.origin.distance_to(target_location)
	var new_position = global_transform.origin
	
	if distance < sheep_distance_run:
		var dir_to_player = global_transform.origin - target_location
		
		new_position = global_transform.origin + dir_to_player
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
			global_transform.origin.x + randi_range(-20, 20), 
			global_transform.origin.y,
			global_transform.origin.z + randi_range(-20, 20))
	
	_is_walking = true


func _on_navigation_agent_3d_velocity_computed(safe_velocity: Vector3) -> void:
	velocity = velocity.move_toward(safe_velocity, 0.25)
	move_and_slide()
