extends Node3D

@onready var player: Player = $Stage/Player
@onready var navigation_region_3d: NavigationRegion3D = $Stage/NavigationRegion3D
@onready var audio_stream_player_3d: AudioStreamPlayer3D = $house2mag/Area3D/AudioStreamPlayer3D

func _physics_process(_delta: float) -> void:
	get_tree().call_group("sheep", "update_target_location", player.global_transform.origin)
	get_tree().call_group("sound_sheep", "update_crouching", player.is_crouching)


func _on_area_3d_area_entered(area: Area3D) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), -10)
	if not audio_stream_player_3d.playing:
		audio_stream_player_3d.play()


func _on_audio_stream_player_3d_finished() -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), 0)
