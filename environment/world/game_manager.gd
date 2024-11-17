extends Node

@onready var timer: Timer = $CycleTimer
@onready var timer_text: RichTextLabel = $MarginContainer/TimerLabel
@onready var score_label: Label = $MarginContainer/ScoreLabel
@onready var max_time: float = 300
@onready var order_manager: OrderManager = %OrderManager
var cycle_started: bool = false

const TIME_STEP: float = 30

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer_text.text = ""
	score_label.text = ""
	#start_cycle()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	update_timer_label()

func start_cycle():
	cycle_started = true
	order_manager.set_give_order(true)
	order_manager.generate_order()
	timer.start(max_time)
	max_time += TIME_STEP

func _on_cycle_timer_timeout() -> void:
	timer.stop()
	order_manager.reset_order()
	score_label.text = "Время вышло!\nЗаказов выполнено: " + str(order_manager.get_orders_completed_count())

func update_timer_label():
	if !timer.paused and !timer.is_stopped():
		timer_text.text = get_time_string()

func get_time_string() -> String:
	var res: String = str(int(timer.time_left) / 60) + ':'
	var i: int =  int(timer.time_left) % 60
	if i < 10:
		res += "0"
	res += str(i)
	return "[color=black]" + res + "[/color]"

func get_cycle_started():
	return cycle_started
