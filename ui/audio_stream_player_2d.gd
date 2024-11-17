extends AudioStreamPlayer2D

@onready var listener: AudioListener2D = $AudioListener2D
var main_menu_audio: AudioStream = preload("res://audio/music/RetroFuture-Clean.mp3")
var game_audio: AudioStream  = preload("res://audio/music/Funky-Chunk.mp3")
var volume = 0
var music_volume = 0
var sfx_volume = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	stream = main_menu_audio
	play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func play_game_music():
	stream = game_audio
	play()

func play_menu_music():
	stream = main_menu_audio
	play()
