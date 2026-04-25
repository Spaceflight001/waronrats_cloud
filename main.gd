extends Node

signal feed
var timer = 0.0

@export var objpool: Array = []
@export var effpool: Array = []

var RatType: Array[String] = ["Thrower"]

@onready var rat = load("res://rat.tscn")

func resize(object: Node, size: float):
	for part in object.get_children():
		if part.is_class("Node3D"):
			part.scale *= size
			part.position *= size
	#object.health *= size

func  _input(event: InputEvent) -> void:
	pass

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	timer += delta
	if timer > 1:
		timer = 0.0
		#var ratclone = rat.instantiate()
		#add_child(ratclone, true)
		#ratclone.scale *= 0.8
		#ratclone.health = 100.0
		#ratclone.position = Vector3(randf_range(-20,20),15,randf_range(-20,20))
		#
		##decide the rat type
		#var norm = randi_range(1,2)
		#if norm == 1:
			#var type = RatType[randf_range(0, RatType.size())]
			#print(type)
			#ratclone.rattype = type
			#if type == "Tennis":
				#resize(ratclone, 1.5)
			#if type == "Armored":
				#resize(ratclone, 2.0)
				#ratclone.armor = 0.9
