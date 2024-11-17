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


func _ready() -> void:
	spawn_points = get_children().slice(1) # Скипаем таймер
	_wait_time = timer.wait_time
	timer.start()
	spawn_sheep()


func spawn_sheep() -> void:
	randomize()
	sheep_collection.shuffle()
	for i in range(len(spawn_points)):
		var instance: Node3D = load(sheep_collection[i % len(sheep_collection)]).instantiate()
		add_child(instance)
		instance.global_transform = spawn_points[i].global_transform
 

func _on_timer_timeout() -> void:
	spawn_sheep()
	timer.wait_time = _wait_time
	timer.start()
