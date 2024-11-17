extends Node

@onready var container = $CenterContainer/VBoxContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	container.visible = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Pause"):
		if container.visible:
			container.visible = false
			Engine.time_scale = 1
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			container.visible = true
			Engine.time_scale = 0
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_resume_button_pressed() -> void:
	container.visible = false
	Engine.time_scale = 1
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _on_menu_button_pressed() -> void:
	Engine.time_scale = 1
	MusicManager.play_menu_music()
	get_tree().change_scene_to_file("res://ui/main_menu.tscn")

func _on_music_button_pressed() -> void:
	MusicManager.music_volume += 100
	MusicManager.music_volume %= 200
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), -MusicManager.music_volume)

func _on_sfx_button_pressed() -> void:
	MusicManager.sfx_volume += 100
	MusicManager.sfx_volume %= 200
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), -MusicManager.sfx_volume)
