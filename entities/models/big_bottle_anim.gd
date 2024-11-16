extends Node3D

@onready var sheep: Node3D = $sheep
@onready var cube: MeshInstance3D = $sheep/Cube
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _on_animation_player_animation_started(anim_name: StringName) -> void:
	sheep.visible = true
		
func start(sheep_color: Color):
	cube.mesh.surface_get_material(0).albedo_color = sheep_color
	animation_player.play("extract")

func decolor_sheep():
	cube.mesh.surface_get_material(0).albedo_color = Color.WHITE

func jump_sheep():
	sheep.jump()
