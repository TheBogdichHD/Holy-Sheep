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

@onready var head: Node3D = $Head
@onready var head_start_position: float = head.position.y

@onready var standing_collision_shape: CollisionShape3D = $StandingCollisionShape
@onready var crouching_collision_shape: CollisionShape3D = $CrouchingCollisionShape
@onready var ray_cast_3d: RayCast3D = $RayCast3D

@onready var direction_ray: RayCast3D = $Head/DirectionRay
@onready var spawn_point: Node3D = $Head/SpawnPoint
@onready var hands_sprite: TextureRect = %HandsSprite
@onready var sheep_sprite: TextureRect = %SheepSprite


var held_object = null
var is_holding_object: bool = false

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity))
		head.rotate_x(deg_to_rad(-event.relative.y * mouse_sensitivity))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))
	elif event is InputEvent:
		if event.is_action_pressed("interact"):
			_interact()

func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("crouch"):
		standing_collision_shape.disabled = true
		crouching_collision_shape.disabled = false
		_current_speed = crouching_speed
		head.position.y = lerp(head.position.y, head_start_position + crouch_depth, delta*lerp_speed)
	elif not ray_cast_3d.is_colliding():
		standing_collision_shape.disabled = false
		crouching_collision_shape.disabled = true
		
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
	_direction = lerp(_direction, (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta*lerp_speed)
	
	if _direction:
		velocity.x = _direction.x * _current_speed
		velocity.z = _direction.z * _current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, _current_speed)
		velocity.z = move_toward(velocity.z, 0, _current_speed)

	move_and_slide()
	
func _interact():
	if is_holding_object:
		sheep_sprite.visible = not sheep_sprite.visible
		held_object.global_transform = spawn_point.global_transform
		get_tree().get_root().add_child(held_object)
		held_object = null
		is_holding_object = false
		return
	if not direction_ray.is_colliding():
		return
	var obj = direction_ray.get_collider()
	if obj.is_in_group("pickable"):
		held_object = obj.duplicate()
		sheep_sprite.visible = not sheep_sprite.visible
		is_holding_object = true
		obj.queue_free()
	pass
