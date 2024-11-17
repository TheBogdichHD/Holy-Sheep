extends Node3D
const SHEPHERD = preload("res://audio/shepherd.ogg")
const SHEPHERD_REVERSE = preload("res://audio/shepherd_reverse.ogg")
var anim_list = ["squash"]
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var audio_stream_player_3d: AudioStreamPlayer3D = $AudioStreamPlayer3D

var in_play = false

func play_random():
	var i = randi_range(0, anim_list.size()-1)
	play_command(anim_list[i])
	
func play_command(command):
	in_play = true
	animation_player.play("shepherd_animations/" + command)
	match command:
		"squash":
			audio_stream_player_3d.stream = SHEPHERD
			audio_stream_player_3d.play()
			await audio_stream_player_3d.finished
			await get_tree().create_timer(randf_range(0, 5)).timeout
			animation_player.play_backwards("shepherd_animations/" + command)
			audio_stream_player_3d.stream = SHEPHERD_REVERSE
			audio_stream_player_3d.play()
			await audio_stream_player_3d.finished
	in_play = false
func clear():
	animation_player.play("RESET")

func is_playing():
	return animation_player.is_playing() or in_play
