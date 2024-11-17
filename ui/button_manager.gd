extends Node

func _on_play_button_pressed():
	MusicManager.play_game_music()
	get_tree().change_scene_to_file("res://environment/map/map.tscn")

func _on_sound_button_pressed() -> void:
	MusicManager.music_volume += 100
	MusicManager.music_volume %= 200
	MusicManager.sfx_volume += 100
	MusicManager.sfx_volume %= 200
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), -MusicManager.music_volume)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), -MusicManager.sfx_volume)

func _on_quit_button_pressed() -> void:
	get_tree().quit()
