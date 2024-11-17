class_name  Spawner
extends Node

@export var sheep: String = "res://entities/sheep/sheep.tscn"
@export var red_sheep: String = "res://entities/sheep/screaming_sheep.tscn"
@export var green_sheep: String = "res://entities/sheep/jump_sheep_remote_transform.tscn"
@export var blue_sheep: String = "res://entities/sheep/sound_sheep.tscn"

@export var timer: Timer
var _wait_time: float

var sheep_collection = [sheep, red_sheep, green_sheep, blue_sheep]
var spawn_points
var sheep_spawned = 0

var sheep_dict = {
	"белый": sheep,
	"красный": red_sheep,
	"зелёный": green_sheep,
	"синий": blue_sheep
}

@onready var order_manager: OrderManager = %OrderManager


func _ready() -> void:
	spawn_points = get_children().slice(1) # Скипаем таймер
	_wait_time = timer.wait_time
	timer.start()
	spawn_sheep()


func spawn_sheep() -> void:
	if not order_manager.is_order_taken():
		return
	randomize()
	#sheep_collection.shuffle()
	#for i in range(len(spawn_points)):
		#var instance: Node3D = load(sheep_collection[i % len(sheep_collection)]).instantiate()
		#add_child(instance)
		#instance.global_transform = spawn_points[i].global_transform

	for s in order_manager.all_ever_requested_sheep.keys():
		if not s in sheep_dict.keys():
			continue
		if order_manager.all_ever_requested_sheep[s] == 0:
			continue
		var instance: Node3D = load(sheep_dict[s]).instantiate()
		add_child(instance)
		var index = sheep_spawned % len(spawn_points)
		instance.global_transform = spawn_points[index].global_transform
		sheep_spawned += 1
	order_manager.reset_all_requested_sheep()
 

func _on_timer_timeout() -> void:
	spawn_sheep()
	timer.wait_time = _wait_time
	timer.start()
