extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var _speed: float = 1.0

signal finished

func set_speed(_value):
	_speed = _value
func walk():
	animation_player.speed_scale = _speed
	animation_player.play("sheep_animations/walk")
	
func stop():
	animation_player.play("RESET")
	
func jump():
	animation_player.play("sheep_animations/jump")

func scream():
	animation_player.play("sheep_animations/scream")

func fall():
	animation_player.play("sheep_animations/fall")

func fear():
	animation_player.play("sheep_animations/fear")

func cling():
	animation_player.play("sheep_animations/cling")
	wait_for_stop()

func is_playing():
	return animation_player.is_playing()

func wait_for_stop():
	await animation_player.animation_finished
	emit_signal("finished")
