extends Node3D
const WIZARD_CAST_1 = preload("res://audio/wizard_cast1.ogg")
const WIZARD_SHOE = preload("res://audio/wizard_shoe.ogg")
const WIZARD_SHOE_REVERSE = preload("res://audio/wizard_shoe_reverse.ogg")

var anim_list = ["cast1", "shoeinator"]
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var audio_stream_player_3d: AudioStreamPlayer3D = $AudioStreamPlayer3D
var in_play = false

func _ready() -> void:
	audio_stream_player_3d.volume_db = -10

func play_random():
	var i = randi_range(0, anim_list.size()-1)
	play_command(anim_list[i])
	
func play_command(command):
	in_play = true
	animation_player.stop()
	animation_player.play("wizard_animations/" + command)
	match command:
		"cast1":
			audio_stream_player_3d.stream = WIZARD_CAST_1
			audio_stream_player_3d.play()
		"shoeinator":
			audio_stream_player_3d.stream = WIZARD_SHOE
			audio_stream_player_3d.play()
			await audio_stream_player_3d.finished
			await get_tree().create_timer(randf_range(0, 3)).timeout
			if animation_player.is_playing():
				await animation_player.animation_finished
			animation_player.play_backwards("wizard_animations/" + command)
			audio_stream_player_3d.stream = WIZARD_SHOE_REVERSE
			audio_stream_player_3d.play()
			await audio_stream_player_3d.finished
	in_play = false
func clear():
	animation_player.stop()

func is_playing():
	return in_play or animation_player.is_playing()

func wait():
	if in_play:
		await animation_player.animation_finished
	in_play = true
	await get_tree().create_timer(.5).timeout
	in_play = false
