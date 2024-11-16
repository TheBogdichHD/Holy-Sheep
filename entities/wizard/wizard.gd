extends Node3D
@onready var timer: Timer = $Timer
@onready var wizard: Node3D = $wizard

func _process(delta: float) -> void:
	if timer.is_stopped():
		timer.start(randf_range(0, 2))
		

func _on_timer_timeout() -> void:
	if not wizard.is_playing():
		wizard.play_random()
