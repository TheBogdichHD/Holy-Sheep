extends StaticBody3D

var _is_player_near = false
var _player_interacted = false

@onready var player: Player
@onready var sliders_control: Control = $Control
@onready var slider_red: HSlider = $Control/HSliderR
@onready var slider_green: HSlider = $Control/HSliderG
@onready var slider_blue: HSlider = $Control/HSliderB
@onready var color_to_adjust = $ColorToAdjust
@onready var base_color = $MeshInstance3D


func _ready() -> void:
	var surface_material: StandardMaterial3D = base_color.mesh.surface_get_material(0)
	surface_material.albedo_color = Color(randf(), randf(), randf())


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


func _on_h_slider_r_value_changed(value: float) -> void:
	_adjust_color()


func _on_h_slider_g_value_changed(value: float) -> void:
	_adjust_color()


func _on_h_slider_b_value_changed(value: float) -> void:
	_adjust_color()
