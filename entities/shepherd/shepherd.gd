extends Node3D
@onready var timer: Timer = $Timer
@onready var model: Node3D = $model
@onready var warning: GPUParticles3D = $Warning.get_child(0)

@onready var _order_manager: OrderManager = %OrderManager

func _process(delta: float) -> void:
	if timer.is_stopped():
		timer.start(randf_range(3.5, 6.5))
		
	if not _order_manager.get_give_order():
		return
		
	if not _order_manager.is_order_taken():
		warning.emitting = true
	else:
		warning.emitting = false
		
func _on_timer_timeout() -> void:
	if not model.is_playing():
		model.play_random()
