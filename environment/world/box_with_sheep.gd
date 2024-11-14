extends StaticBody3D

var _is_player_near = false
var _player_interacted = false

@export var sheep_path: String = "res://entities/sheep/sheep.tscn"

@onready var player: Player
@onready var sliders_control: Control = $Control
@onready var slider_red: HSlider = $Control/HSliderR
@onready var slider_green: HSlider = $Control/HSliderG
@onready var slider_blue: HSlider = $Control/HSliderB
@onready var color_to_adjust = $ColorToAdjust
@onready var base_color = $MeshInstance3D
var sheep


func _ready() -> void:
	var surface_material: StandardMaterial3D = base_color.mesh.surface_get_material(0)
	surface_material.albedo_color = Color(randf(), randf(), randf())
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
	var surface_material: StandardMaterial3D = color_to_adjust.mesh.surface_get_material(0)
	surface_material.albedo_color = Color(slider_red.value/255, slider_green.value/255, slider_blue.value/255)
	if _is_solved():
		solve()


func _on_h_slider_r_value_changed(value: float) -> void:
	_adjust_color()


func _on_h_slider_g_value_changed(value: float) -> void:
	_adjust_color()


func _on_h_slider_b_value_changed(value: float) -> void:
	_adjust_color()
	
	
func _is_solved() -> bool:
	var m1: StandardMaterial3D = base_color.mesh.surface_get_material(0)
	var m2: StandardMaterial3D = color_to_adjust.mesh.surface_get_material(0)
	var c1: Color = m1.albedo_color
	var c2: Color = m2.albedo_color
	var eps = 0.08
	return color_distance(c1, c2) < eps


func color_distance(c1: Color, c2: Color) -> float:
	var r = c1.r - c2.r
	var g = c1.g - c2.g
	var b = c1.b - c2.b
	return sqrt(r*r + g*g + b*b)


func solve():
	_stop_interaction()
	var instance: Node3D = sheep.instantiate()
	get_parent_node_3d().add_child(instance)
	instance.global_transform = global_transform
	queue_free()
