extends StaticBody3D

@onready var area = $Area3D
@onready var hint = $Sprite3D
@onready var hint_text = $Sprite3D/SubViewport/Label

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		if not OrderManager.is_order_taken():
			OrderManager.take_order()
			hint_text.text = "хачю "
			var order = OrderManager.get_order()
			for color in order.keys():
				if order[color] > 0:
					hint_text.text += str(order[color]) + " " + color + " "
			hint_text.text += "барашэк"
		hint.visible = true


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		hint.visible = false
