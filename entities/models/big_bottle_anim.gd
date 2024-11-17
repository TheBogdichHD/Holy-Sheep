extends Node3D

@onready var sheep: Node3D = $sheep
@onready var cube: MeshInstance3D = $sheep/Cube
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var player: Player

var _is_player_near = false
var cur_sheep_color = Color(0,0,0,0)

func _ready() -> void:
	var shader = get_parent().get_child(2).get_child(0).mesh.surface_get_material(0).next_pass
	shader.set_shader_parameter("size", 0.0)
	get_parent().get_child(2).get_child(1).mesh.surface_get_material(0).albedo_color = cur_sheep_color

func _input(event: InputEvent) -> void:
	if not _is_player_near:
		return
		
	if event is InputEvent:
		if event.is_action_pressed("interact") and player.is_holding_object:
			#условие, что овца соответсвует заказу
			player.delete_sheep = true
			start(player.current_sheep_color)


func _on_animation_player_animation_started(anim_name: StringName) -> void:
	sheep.visible = true

func start(sheep_color: Color):
	cur_sheep_color = sheep_color
	cube.mesh.surface_get_material(0).albedo_color = cur_sheep_color
	animation_player.play("extract")

func decolor_sheep():
	cube.mesh.surface_get_material(0).albedo_color = Color.WHITE
	var water_color = Color(cur_sheep_color.r, cur_sheep_color.g, cur_sheep_color.b, 0.5)
	get_parent().get_child(2).get_child(1).mesh.surface_get_material(0).albedo_color = water_color

func jump_sheep():
	sheep.jump()


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		_is_player_near = true
		player = body


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		_is_player_near = false

func enable_outline():
	var shader = get_parent().get_child(2).get_child(0).mesh.surface_get_material(0).next_pass
	shader.set_shader_parameter("size", 1.1)


func disable_outline():
	var shader = get_parent().get_child(2).get_child(0).mesh.surface_get_material(0).next_pass
	shader.set_shader_parameter("size", 0.0)


func _on_area_3d_area_entered(area: Area3D) -> void:
	if area.is_in_group("player"):
		enable_outline()


func _on_area_3d_area_exited(area: Area3D) -> void:
	if area.is_in_group("player"):
		disable_outline()
