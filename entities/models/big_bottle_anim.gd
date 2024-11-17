extends Node3D

@onready var sheep: Node3D = $sheep
@onready var cube: MeshInstance3D = $sheep/Cube
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var player: Player

var _is_player_near = false

func _input(event: InputEvent) -> void:
	if not _is_player_near:
		return
		
	if event is InputEvent:
		if event.is_action_pressed("interact") and player.is_holding_object:
			player.delete_sheep = true
			print(true)
			start(player.current_sheep_color)


func _on_animation_player_animation_started(anim_name: StringName) -> void:
	sheep.visible = true

func start(sheep_color: Color):
	cube.mesh.surface_get_material(0).albedo_color = sheep_color
	animation_player.play("extract")

func decolor_sheep():
	cube.mesh.surface_get_material(0).albedo_color = Color.WHITE

func jump_sheep():
	sheep.jump()


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		_is_player_near = true
		player = body


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		_is_player_near = false
