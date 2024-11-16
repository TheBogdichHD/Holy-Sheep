extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var _speed: float = 1.0

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
