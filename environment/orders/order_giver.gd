extends StaticBody3D

@onready var area = $Area3D

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player") and !OrderManager.is_order_taken():
		OrderManager.take_order()
		print("Получили заказ:", OrderManager.get_order())
		# TODO: отображение заказа игроку
