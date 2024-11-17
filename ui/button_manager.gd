extends Node

func _on_play_button_pressed():
	MusicManager.play_game_music()
	get_tree().change_scene_to_file("res://environment/map/map.tscn")

func _on_sound_button_pressed() -> void:
	var is_mute = AudioServer.is_bus_mute(AudioServer.get_bus_index("SFX")) or AudioServer.is_bus_mute(AudioServer.get_bus_index("Music"))
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Music"), not is_mute)
	AudioServer.set_bus_mute(AudioServer.get_bus_index("SFX"), not is_mute)

func _on_quit_button_pressed() -> void:
	get_tree().quit()
