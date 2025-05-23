extends Node3D
@onready var timer: Timer = $Timer
@onready var game_manager = $"../../GameManager"

var _is_player_near = false
@onready var model: Node3D = $model
@onready var label_3d: Label3D = $Label3D

@onready var warning: GPUParticles3D = $Warning.get_child(0)

func _ready() -> void:
	warning.emitting = true

func _process(delta: float) -> void:
	if timer.is_stopped():
		timer.start(randf_range(3.5, 6.5))

func _input(event: InputEvent) -> void:
	if event is InputEvent:
		if event.is_action_pressed("interact") and _is_player_near and !game_manager.get_cycle_started():
			model.clear()
			model.play_command("questgive")
			game_manager.start_cycle()
			label_3d.visible = true
			label_3d.text = tr("Иди к пастуху!")
			warning.emitting = false

func _on_timer_timeout() -> void:
	if not model.is_playing():
		model.play_random()

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		_is_player_near = true

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		_is_player_near = false
