extends Node

var _sheep_colors = ["white", "black", "red"]
var _current_order = {}

var _order_taken = false
var _orders_completed = 0
var _max_sheep_in_order


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	generate_order()


func generate_order():
	reset_order()
	var sheep_in_order = 0
	while sheep_in_order == 0:
		for color in _sheep_colors:
			var sheep_to_add = randi_range(0, _orders_completed + 2)
			_current_order[color] += min(sheep_to_add, _max_sheep_in_order - sheep_in_order)
			sheep_in_order += _current_order[color]


func is_order_completed(collected_sheep):
	for color in _sheep_colors:
		if collected_sheep[color] < _current_order[color]:
			return false
	return true


func reset_order():
	_order_taken = false
	for color in _sheep_colors:
		_current_order[color] = 0
	randomize()
	_sheep_colors.shuffle() # чтоб оно не выдавало все заказы с овцами из начала списка
	_max_sheep_in_order = _orders_completed * 2 + 1


func get_order():
	return _current_order
	

func is_order_taken():
	return _order_taken
	
	
func take_order():
	_order_taken = true


func complete_order():
	_orders_completed += 1
	generate_order()
