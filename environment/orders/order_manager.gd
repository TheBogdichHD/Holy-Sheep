extends Node

var _sheep_colors = ["белый"]
var _current_order = {}
var _collected_sheep = {}

var _order_taken = false
var _orders_completed = 0
var _max_sheep_in_order


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	generate_order()


## Сгенерировать новый заказ
func generate_order() -> void:
	reset_order()
	var sheep_in_order = 0
	while sheep_in_order == 0:
		for color in _sheep_colors:
			#var sheep_to_add = randi_range(0, _orders_completed + 2)
			var sheep_to_add = randi_range(0, 1)
			_current_order[color] += min(sheep_to_add, _max_sheep_in_order - sheep_in_order)
			sheep_in_order += _current_order[color]
			if sheep_in_order > _max_sheep_in_order:
				break


## Проверить, выполнен ли заказ
func is_order_completed() -> bool:
	for color in _sheep_colors:
		if _collected_sheep[color] < _current_order[color]:
			return false
	return true


## Сбросить состояние заказа
func reset_order() -> void:
	_order_taken = false
	for color in _sheep_colors:
		_current_order[color] = 0
		_collected_sheep[color] = 0
	randomize()
	_sheep_colors.shuffle() # чтоб оно не выдавало все заказы с овцами из начала списка
	#_max_sheep_in_order = _orders_completed * 2 + 1
	_max_sheep_in_order = 1 # упрощение


## Получить текущий заказ
func get_order() -> Dictionary:
	return _current_order
	

## Проверить, взят ли заказ
func is_order_taken() -> bool:
	return _order_taken
	

## Взять новый заказ
func take_order() -> void:
	_order_taken = true


## Завершить текущий заказ
func complete_order() -> void:
	_orders_completed += 1
	generate_order()


## Собрать овцу
func collect_sheep(sheep_color: String) -> void:
	_collected_sheep[sheep_color] += 1