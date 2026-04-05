extends Node

signal feed
var timer = 0.0

@export var objpool: Array = []
@export var effpool: Array = []

var RatType: Array[String] = ["Soldier", "Tennis"]

@onready var rat = load("res://rat.tscn")

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
		var ratclone = rat.instantiate()
		add_child(ratclone, true)
		ratclone.scale *= 0.8
		ratclone.health = 100.0
		ratclone.position = Vector3(randf_range(-20,20),5,randf_range(-20,20))
		
		#decide the rat type
		var norm = randi_range(1,4)
		if norm == 1:
			var type = RatType[randf_range(0, RatType.size()-1)]
			print(type)
			if type == "Soldier":
				ratclone.scale *= 1/0.8
