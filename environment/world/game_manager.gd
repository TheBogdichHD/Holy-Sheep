extends Node

@onready var timer: Timer = $CycleTimer
@onready var timer_text: Label = $MarginContainer/TimerLabel
@onready var score_label: Label = $MarginContainer/VBoxContainer/ScoreLabel
@onready var order_label: Label = $MarginContainer/OrderLabel
@onready var max_time: float = 420
@onready var order_manager: OrderManager = %OrderManager
var cycle_started: bool = false

const TIME_STEP: float = 30

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer_text.text = ""
	score_label.text = ""
	order_label.text = ""
	#start_cycle()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	update_timer_label()
	if order_manager.is_order_taken():
		order_label.text = tr("juice") + "\n" + get_current_color()
	elif cycle_started:
		order_label.text = tr("Иди к пастуху!")
	else:
		order_label.text = ""

func start_cycle():
	cycle_started = true
	order_manager.set_give_order(true)
	order_manager.generate_order()
	timer.start(max_time)
	max_time += TIME_STEP

func _on_cycle_timer_timeout() -> void:
	timer.stop()
	order_manager.reset_order()
	$MarginContainer/VBoxContainer.visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	Engine.time_scale = 0
	score_label.text = tr("Время вышло!") + "\n" + tr("Заказов выполнено: ") + str(order_manager.get_orders_completed_count())

func update_timer_label():
	if !timer.paused and !timer.is_stopped():
		timer_text.text = get_time_string()

func get_time_string() -> String:
	var res: String = str(int(timer.time_left) / 60) + ':'
	var i: int =  int(timer.time_left) % 60
	if i < 10:
		res += "0"
	res += str(i)
	return res

func get_cycle_started():
	return cycle_started


func get_current_color() -> String:
	var text = ""
	var current_order = order_manager.get_order()
	for color in current_order.keys():
		if current_order[color] > 0:
			text = color
			break
	return tr(text) + " "


func _on_button_pressed() -> void:
	Engine.time_scale = 1
	MusicManager.play_game_music()
	get_tree().reload_current_scene()
