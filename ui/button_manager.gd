extends Node

func _on_play_button_pressed():
	get_tree().change_scene_to_file("res://environment/world/world.tscn")

func _on_sound_button_pressed() -> void:
	pass

func _on_quit_button_pressed() -> void:
	pass
