extends Node3D

@onready var player: Player = $Stage/Player
@onready var navigation_region_3d: NavigationRegion3D = $Stage/NavigationRegion3D

func _physics_process(_delta: float) -> void:
	get_tree().call_group("sheep", "update_target_location", player.global_transform.origin)
	get_tree().call_group("sound_sheep", "update_crouching", player.is_crouching)
