extends Node3D

@onready var main: Node = get_tree().root.get_child(0)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _input(event: InputEvent) -> void:
	if get_parent().name != "Backpack":
		if event.is_action_pressed("fire"):
			var cam = get_parent().get_node("Camera3D")
			var projectile = load("res://projectile.tscn").instantiate()
			main.add_child(projectile)
			projectile.position = cam.global_position + -cam.global_basis.z
			projectile.linear_velocity = -cam.global_basis.z * 40

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if get_parent().name != "Backpack":
		rotation = get_parent().get_node("Camera3D").rotation
