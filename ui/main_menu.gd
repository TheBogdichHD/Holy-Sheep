extends Control


@onready var polish_sheep: Node3D = $SubViewportContainer/SubViewport/polish_sheep
var speed = 1

func _ready() -> void:
	polish_sheep.get_child(6).play("dance")

func _process(delta: float) -> void:
	polish_sheep.rotate_y(delta*speed)
