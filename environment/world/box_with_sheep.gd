extends StaticBody3D

var _is_player_near = false
var _player_interacted = false

@export var sheep_path: String = "res://entities/sheep/sheep_from_box.tscn"

@onready var player: Player
@onready var sliders_control: Control = $Control
@onready var slider_red: HSlider = $Control/HSliderR
@onready var slider_green: HSlider = $Control/HSliderG
@onready var slider_blue: HSlider = $Control/HSliderB
@onready var color_to_adjust = $ColorToAdjust
@onready var base_color_mesh = $MeshInstance3D

var sheep
var _base_color: Color
var _adjustable_color: Color

func _ready() -> void:
	randomize()
	_base_color = Color(randf(), randf(), randf())
	var surface_material: StandardMaterial3D = base_color_mesh.mesh.surface_get_material(0)
	var duplicate_material: StandardMaterial3D = surface_material.duplicate(0)
	duplicate_material.albedo_color = _base_color
	base_color_mesh.set_surface_override_material(0, duplicate_material)
	sheep = load(sheep_path)


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		_is_player_near = true
		player = body


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		_is_player_near = false


func _unhandled_input(event: InputEvent) -> void:
	if not _is_player_near:
		return
		
	if event is InputEvent:
		if event.is_action_pressed("interact"):
			if _player_interacted:
				_stop_interaction()
			else:
				_interact()


func _interact():
	_player_interacted = true
	sliders_control.visible = true
	_set_player_enabled(false)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	

func _stop_interaction():
	sliders_control.visible = false
	_player_interacted = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	_set_player_enabled(true)


func _set_player_enabled(value: bool):
	player.set_physics_process(value)
	player.set_process_input(value)
	player.set_process_unhandled_input(value)


func _adjust_color():
	_adjustable_color = Color(slider_red.value/255, slider_green.value/255, slider_blue.value/255)
	var surface_material: StandardMaterial3D = color_to_adjust.mesh.surface_get_material(0)
	var duplicate_material: StandardMaterial3D = surface_material.duplicate(0)
	duplicate_material.albedo_color = _adjustable_color
	color_to_adjust.set_surface_override_material(0, duplicate_material)
	if _is_solved():
		_solve()


func _on_h_slider_r_value_changed(value: float) -> void:
	_adjust_color()


func _on_h_slider_g_value_changed(value: float) -> void:
	_adjust_color()


func _on_h_slider_b_value_changed(value: float) -> void:
	_adjust_color()
	
	
func _is_solved() -> bool:
	var eps = 0.08
	return _color_distance(_adjustable_color, _base_color) < eps


func _color_distance(c1: Color, c2: Color) -> float:
	var r = c1.r - c2.r
	var g = c1.g - c2.g
	var b = c1.b - c2.b
	return sqrt(r*r + g*g + b*b)


func _solve():
	_stop_interaction()
	var instance: Node3D = sheep.instantiate()
	get_parent_node_3d().add_child(instance)
	instance.global_transform = global_transform
	_repaint_sheep(instance)
	queue_free()

func _repaint_sheep(instance):
	instance.sheep_color = _base_color
	var sheep_model = instance.get_node("SheepModel").get_child(0)
	var surface_material: StandardMaterial3D = sheep_model.mesh.surface_get_material(0)
	var duplicate_material: StandardMaterial3D = surface_material.duplicate(0)
	duplicate_material.albedo_color = _base_color
	sheep_model.set_surface_override_material(0, duplicate_material)
