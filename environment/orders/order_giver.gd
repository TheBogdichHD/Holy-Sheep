extends StaticBody3D

@onready var area = $Area3D
@onready var hint = $Sprite3D
@onready var hint_text = $Sprite3D/SubViewport/Label
@onready var order_manager = $".."

func _on_area_3d_body_entered(body: Node3D) -> void:
	if !order_manager.get_give_order():
		hint.visible = false
	elif body.is_in_group("player"):
		if not order_manager.is_order_taken():
			order_manager.take_order()
			hint_text.text = "хачю "
			var order = order_manager.get_order()
			for color in order.keys():
				if order[color] > 0:
					hint_text.text += str(order[color]) + " " + color + " "
			hint_text.text += "барашэк"
		hint.visible = true


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		hint.visible = false
