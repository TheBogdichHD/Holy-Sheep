extends Node3D

var _is_player_near = false
@onready var hint = $Sprite3D
@onready var hint_text = $Sprite3D/SubViewport/Label

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		_is_player_near = true
	if body.is_in_group("sheep") and _is_player_near:
		if OrderManager.is_order_taken():
			OrderManager.collect_sheep(body.get_node("SheepColor").color)
			body.queue_free()
			if OrderManager.is_order_completed():
				OrderManager.complete_order()
				hint_text.text = "ЗАКАЗ ВЫПОЛНЕН"
				hint.visible = true
		else:
			hint_text.text = "Сначала возьмите заказ!"
			hint.visible = true


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		_is_player_near = false
		hint.visible = false
