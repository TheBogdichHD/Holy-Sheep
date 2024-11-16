extends Node3D

var anim_list = ["cast1", "shoeinator"]
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func play_random():
	var i = randi_range(0, anim_list.size()-1)
	animation_player.play("wizard_animations/" + anim_list[i])

func clear():
	animation_player.play("RESET")

func is_playing():
	return animation_player.is_playing()
