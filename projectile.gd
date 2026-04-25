extends RigidBody3D

@onready var main = get_tree().root.get_child(0)

var lifetime: float = 0.0
var destroy: bool = false

var hitcolor:Color = Color(1,0.5,0.5)
var killcolor:Color = Color(0.8,0,0)

@export var maxdist: float

func get_parts_in_radius(position: Vector3, radius: float, collision_mask: int = 0xFFFFFFFF):
	# 1. Get the direct physics state
	var space_state = get_world_3d().direct_space_state
	
	# 2. Create the sphere shape query
	var shape = SphereShape3D.new()
	shape.radius = radius
	
	# 3. Setup the query parameters
	var query = PhysicsShapeQueryParameters3D.new()
	query.shape = shape
	query.transform = Transform3D(Basis(), position)
	query.collision_mask = collision_mask # Filter layers if needed
	
	# 4. Perform the query
	# Returns an array of dictionaries with 'collider' (the node)
	var result = space_state.intersect_shape(query)
	
	return result

func frag():
	var raycast = $RayCast3D
	raycast.reparent(self)
	var x = deg_to_rad(360 * ((randf() * 2) - 1))
	var y = deg_to_rad(360 * ((randf() * 2) - 1))
	var z = deg_to_rad(360 * ((randf() * 2) - 1))
	var dir = Vector3(0,0,100).rotated(Vector3.UP, y).rotated(Vector3.FORWARD, z).rotated(Vector3.LEFT, x)
	raycast.target_position = dir
	raycast.force_raycast_update()
	if raycast.get_collider() != null and raycast.get_collider().name.begins_with("Rat"):
		raycast.get_collider().health -= 5
		main.feed.emit(str(5), hitcolor)

func explode():
	if destroy == false:
		$ExplodeSound.play(0.05)
		var parts = get_parts_in_radius(position, 20)
		print(parts)
		for part in parts:
			if part["collider"].name.begins_with("Rat"):
				var dist: float = part["collider"].position.distance_squared_to(position)
				if dist <= maxdist:
					var reduc: float = (maxdist - dist) / maxdist
					var simple: float = float(roundf(200 * reduc * 10)/10)
					part["collider"].health -= 200 * reduc
					main.feed.emit(str(simple), hitcolor)
		destroy = true
		
		var char = main.get_node("Character")
		var cam = char.get_node("Camera3D")
		var camdist = position.distance_to(cam.global_position)
		if camdist <= maxdist * 5:
			var reduc: float = (maxdist * 5- camdist) / (maxdist * 5)
			var x = randf()-randf()
			var y = randf()-randf()
			var z = randf()-randf()
			char.camvel += Vector3(x,y,z) * reduc
			char.camshake += 8 * reduc
			if camdist <= maxdist:
				var reduc2: float = (maxdist - camdist) / maxdist
				char.health -= 200 * reduc2
		
		set_physics_process(false)
		$CollisionShape3D.disabled = true
		freeze = true
		hide()
		lifetime = 0.0
		
		var explode = load("res://explosion.tscn").instantiate()
		main.add_child(explode)
		explode.position = position
		explode.scale *= 2
		explode.get_node("GPUParticles3D").restart()
		explode.get_node("Smoke").restart()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	lifetime += delta
	
	if lifetime > 5:
		explode()
	if destroy == true and lifetime > 5:
		queue_free()



func _on_body_entered(body: Node) -> void:
	if body.name.begins_with("Rat") and linear_velocity.length() > 10:
		if destroy == false:
			body.health -= 10
			main.feed.emit(str(10), hitcolor)
	explode()
