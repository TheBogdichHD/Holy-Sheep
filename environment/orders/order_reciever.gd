extends Node3D

var _is_player_near = false
@onready var hint = $Label3D
@onready var hint_text = $Label3D
@onready var order_manager: OrderManager = $".."
@onready var juice_extractor = $"../../JuiceExtractor/big_bottle"
@onready var player = $"../../Player"
@onready var warning: GPUParticles3D = $Warning.get_child(0)

func _process(delta: float) -> void:
	if order_manager.is_order_taken():
		warning.emitting = true
	else:
		warning.emitting = false

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		_is_player_near = true
	if !order_manager.get_give_order():
		hint.visible = false
	elif body.is_in_group("sheep") and _is_player_near:
		if order_manager.is_order_taken():
			var sheep_color = body.get_node("SheepColor").color
			if order_manager.get_order()[sheep_color] > 0:
				order_manager.collect_sheep(body.get_node("SheepColor").color)
				body.queue_free()
				if order_manager.is_order_completed():
					order_manager.complete_order()
					juice_extractor.start(player.current_sheep_color)
					hint_text.text = "ЗАКАЗ ВЫПОЛНЕН"
					hint.visible = true
			else:
				hint_text.text = "НЕ ТОТ ЦВЕТ!"
				hint.visible = true
		else:
			hint_text.text = "СНАЧАЛА ВОЗЬМИТЕ ЗАКАЗ!"
			hint.visible = true


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		_is_player_near = false
		hint.visible = false
