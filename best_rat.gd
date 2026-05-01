extends Node3D

var health = 0
@onready var parent = get_parent()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func get_all_descendants(node):
	var descendants = []
	for child in node.get_children():
		descendants.append(child)
		descendants.append_array(get_all_descendants(child))
	return descendants

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if parent.health < health:
		get_node("Armature/Body/Head").material_overlay.albedo_color.a = 0.5
		get_node("Armature/Body/Tail").material_overlay.albedo_color.a = 0.5
		get_node("Armature/Skeleton3D/Body").material_overlay.albedo_color.a = 0.5
		pass
	get_node("Armature/Body/Head").material_overlay.albedo_color.a -= delta
	get_node("Armature/Body/Tail").material_overlay.albedo_color.a -= delta
	get_node("Armature/Skeleton3D/Body").material_overlay.albedo_color.a -= delta
	health = parent.health
