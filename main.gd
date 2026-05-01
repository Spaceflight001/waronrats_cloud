extends Node

signal feed
var timer = 0.0

@export var rats: int = 0
@export var objpool: Array = []
@export var effpool: Array = []

var RatType: Array[String] = ["Armored"]

@onready var rat = load("res://rat.tscn")

func resize(object: Node, size: float):
	for part in object.get_children():
		if part.is_class("Node3D"):
			part.scale *= size
			part.position *= size
			print("scaled " + part.name)
	#object.health *= size

func  _input(event: InputEvent) -> void:
	pass

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	timer += delta
	if timer > 2 and rats < 50:
		timer = 0.0
		rats += 1
		var ratclone = rat.instantiate()
		add_child(ratclone, true)
		ratclone.health = 100.0
		ratclone.position = Vector3(randf_range(-20,20),15,randf_range(-20,20))
		
		#decide the rat type
		var norm = randi_range(1,2)
		if norm == 1:
			var type = RatType[randf_range(0, RatType.size())]
			print(type)
			ratclone.rattype = type
			if type == "Tennis":
				resize(ratclone, 1.5)
			if type == "Armored":
				resize(ratclone, 2.0)
				ratclone.armor = 0.9
