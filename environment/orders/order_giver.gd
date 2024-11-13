extends StaticBody3D

@onready var area = $Area3D
@onready var hint = $Sprite3D
@onready var order_data = $Sprite3D/SubViewport/Label

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		if not OrderManager.is_order_taken():
			OrderManager.take_order()
			order_data.text = "хачю "
			var order = OrderManager.get_order()
			for color in order.keys():
				if order[color] > 0:
					order_data.text += str(order[color]) + " " + color + " "
			order_data.text += "барашэк"
		hint.visible = true


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		hint.visible = false
