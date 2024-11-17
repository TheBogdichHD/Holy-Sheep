extends Node

func _on_play_button_pressed():
	MusicManager.play_game_music()
	get_tree().change_scene_to_file("res://environment/map/map.tscn")

func _on_sound_button_pressed() -> void:
	MusicManager.volume += 100
	MusicManager.volume %= 200
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), -MusicManager.volume)

func _on_quit_button_pressed() -> void:
	get_tree().quit()
