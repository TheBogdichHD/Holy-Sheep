class_name Player
extends CharacterBody3D


@export var walking_speed = 5.0
@export var sprinting_speed = 8.0
@export var crouching_speed = 3.0
@export var jump_velocity = 4.5

@export var crouch_depth = -0.5

@export var mouse_sensitivity = 0.25

@export var lerp_speed = 10.0


var _current_speed = 5.0
var _direction = Vector3.ZERO
var _fov = 75
var additional_velocity = Vector3.ZERO

@onready var head: Node3D = $Head
@onready var head_start_position: float = head.position.y
@onready var camera_3d: Camera3D = $Head/Camera3D

@onready var standing_collision_shape: CollisionShape3D = $StandingCollisionShape
@onready var crouching_collision_shape: CollisionShape3D = $CrouchingCollisionShape
@onready var ray_cast_3d: RayCast3D = $RayCast3D

@onready var direction_ray: RayCast3D = $Head/DirectionRay
@onready var spawn_point: Node3D = $Head/SpawnPoint
@onready var sheep_model: Node3D = %SheepModel

@onready var dark_sheep_spawn_point: Node3D = $DarkSheepSpawnPoint
@onready var dark_sheep_spawn_timer = $DarkSheepSpawnPoint/DarkSheepSpawnTimer
@onready var cling_timer: Timer = $Head/ClingTimer

@onready var audiosource: AudioStreamPlayer3D = $AudioStreamPlayer3D
var slurp = preload("res://audio/slurp.mp3")
var dark_sheep_path = "res://entities/sheep/dark_sheep.tscn"
var dark_sheep

var held_object = null
var is_holding_object: bool = false
var is_crouching = false
var current_sheep_color = Color(0,0,0)
var delete_sheep = false


func _ready() -> void:
	audiosource.volume_db = 10
	audiosource.stream = slurp
	dark_sheep_spawn_timer.start()
	dark_sheep = load(dark_sheep_path)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:
	if Engine.time_scale == 1 and event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity))
		head.rotate_x(deg_to_rad(-event.relative.y * mouse_sensitivity))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))
	if event.is_action_pressed("interact"):
		_interact()
		delete_sheep = false
	if Input.is_action_pressed("zoom"):
		camera_3d.fov = _fov - 40
	if Input.is_action_just_released("zoom"):
		camera_3d.fov = _fov

func _physics_process(delta: float) -> void:
	if is_holding_object and cling_timer.is_stopped() and not sheep_model.is_playing():
		cling_timer.start(randf_range(3, 5))
	if Input.is_action_pressed("crouch"):
		standing_collision_shape.disabled = true
		crouching_collision_shape.disabled = false
		is_crouching = true
		_current_speed = crouching_speed
		head.position.y = lerp(head.position.y, head_start_position + crouch_depth, delta*lerp_speed)
	elif not ray_cast_3d.is_colliding():
		standing_collision_shape.disabled = false
		crouching_collision_shape.disabled = true
		is_crouching = false
		head.position.y = lerp(head.position.y, head_start_position, delta*lerp_speed)
		if Input.is_action_pressed("sprint"):
			_current_speed = sprinting_speed
		else:
			_current_speed = walking_speed
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity

	# Get the input direction and handle the movement/deceleration.
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	_direction = lerp(_direction, (transform.basis * Vector3(input_dir.x, 0, input_dir.y) + additional_velocity).normalized(), delta*lerp_speed)
	if _direction:
		velocity.x = _direction.x * _current_speed
		velocity.z = _direction.z * _current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, _current_speed)
		velocity.z = move_toward(velocity.z, 0, _current_speed)
	#velocity += additional_velocity
	move_and_slide()


func _interact():
	if is_holding_object:
		if delete_sheep:
			held_object = null
			is_holding_object = false
			sheep_model.visible = false
			return
		held_object.global_transform = spawn_point.global_transform
		held_object.rotation = Vector3.ZERO
		get_tree().get_root().add_child(held_object)
		held_object = null
		is_holding_object = false
		sheep_model.visible = false
		return
	if not direction_ray.is_colliding():
		return
	var obj = direction_ray.get_collider()
	if obj.is_in_group("pickable") or obj.is_in_group("sheep"):
		if obj.name == "bottle":
			if obj.get_child(1).mesh.surface_get_material(0).albedo_color != Color(0,0,0,0):
				audiosource.play()
			
			obj.get_child(1).mesh.surface_get_material(0).albedo_color = Color(0,0,0,0)
			return
		
		var cube: MeshInstance3D = sheep_model.get_child(0)
		var surface_material: ShaderMaterial = cube.mesh.surface_get_material(0)
		var dup_surface_material: ShaderMaterial = surface_material.duplicate(true)
		
		dup_surface_material.set_shader_parameter("albedo", obj.sheep_color)
		current_sheep_color = obj.sheep_color
		
		cube.set_surface_override_material(0, dup_surface_material)
		
		if obj is JumpSheep:
			var parent = obj.get_parent()
			obj.global_position = parent.global_position
			obj = parent
		
		held_object = obj.duplicate()
		sheep_model.visible = true
		is_holding_object = true
		obj.queue_free()


func _on_dark_sheep_spawn_timer_timeout() -> void:
	var instance: Node3D = dark_sheep.instantiate()
	get_parent_node_3d().add_child(instance)
	instance.global_transform = dark_sheep_spawn_point.global_transform
	

	dark_sheep_spawn_timer.wait_time = randi_range(20, 30)
	dark_sheep_spawn_timer.start()


func _on_cling_timer_timeout() -> void:
	if not sheep_model.is_playing():
		sheep_model.cling()
		await sheep_model.finished
		sheep_model.stop()
