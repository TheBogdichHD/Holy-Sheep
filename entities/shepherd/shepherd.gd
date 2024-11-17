extends Node3D
@onready var timer: Timer = $Timer
@onready var model: Node3D = $model

func _process(delta: float) -> void:
	if timer.is_stopped():
		timer.start(randf_range(3.5, 6.5))
		
func _on_timer_timeout() -> void:
	if not model.is_playing():
		model.play_random()
