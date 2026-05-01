extends RigidBody3D

#states
enum States { IDLE, WAIT, MOVE }
var state:States = States.IDLE

var lastability: float = 10.0

@export var rattype: String = "Normal"
@export var health: float = 0.0
@export var armor: float = 0.0

var lastjump: float = 5.0
var lastdamage: float = 0.0
@onready var collray:RayCast3D = $CollisionRay
@onready var main:Node = get_tree().root.get_child(0)
@onready var nav_agent:NavigationAgent3D = $NavigationAgent

var isonfloor: bool = true

var killcolor:Color = Color(0.8,0,0)

var floornormal: Vector3 = Vector3.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_node("rat_legged/AnimationPlayer").play("Run")

#calls when idle
func _on_idle():
	pass

#throwing direction calculation function
func get_3d_launch_angles(start_pos: Vector3, target_pos: Vector3, velocity: float) -> Array:
	var g = -ProjectSettings.get_setting("physics/3d/default_gravity")
	
	# Horizontal distance (X/Z distance)
	var diff = target_pos - start_pos
	var x = Vector2(diff.x, diff.z).length()
	
	# Vertical distance (Height difference)
	var y = diff.y
	
	var v2 = velocity * velocity
	var v4 = v2 * v2
	
	# Calculate the value under the square root (discriminant)
	var root_val = v4 - g * (g * (x * x) + 2 * y * v2)
	
	if root_val < 0:
		push_warning("Target is out of reach at this velocity.")
		return []
	
	var root = sqrt(root_val)
	
	# Two possible solutions (high arc and low arc)
	var angle_low = atan((v2 - root) / (g * x))
	var angle_high = atan((v2 + root) / (g * x))
	
	return [angle_low, angle_high]


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	lastjump += delta
	lastdamage += delta
	lastability += delta
	
	var playerpos = get_tree().root.get_child(0).find_child("Character").position + get_tree().root.get_child(0).find_child("Character").velocity
	
	if collray.is_colliding():
		linear_velocity.y += -9.8 * delta
		#linear_velocity += collray.get_collision_normal() * Vector3(0,-29.4,0) * delta
	else:
		linear_velocity.y += -9.8 * 3 * delta
	
	
	if $JumpRaycast.get_collider() != null:
		if lastjump > 2.0:
			lastjump = 0.0
			linear_velocity.y += 10
	
	var look: Vector3
	get_node("rat_legged/AnimationPlayer").speed_scale = 5 / $Sizer.scale.x
	
	#state machine
	match state:
		States.IDLE:
			_on_idle()
	
	#move the rat forward
	linear_velocity += -global_basis.z * 10 * delta
	
	#kill if fall
	if global_position.y < -100:
		health = 0.0
	
	#health logic
	if health <= 0.0:
		main.feed.emit("KILLED RAT", killcolor, 100)
		main.get_node("Killmarker").play()
		main.rats -= 1
		queue_free()
	
	#look at player
	var lookat = global_transform.looking_at(playerpos, Vector3.UP)
	global_transform = global_transform.interpolate_with(lookat, 6 * delta)
	rotation.x = 0
	rotation.z = 0
	
	#deal damage if player touches rat
	var colliders = get_colliding_bodies()
	for collider in colliders:
		if collider.name == "Character" and lastdamage > 1:
			lastdamage = 0.0
			collider.health = move_toward(collider.health, 0, 5)
			var mult: float = collider.health / 100
			main.get_node("Buttons/Sideblack").modulate.a = 1
			if collider.health > 0:
				main.get_node("Character").camvel += Vector3(mult * (randf() - randf()),mult * (randf() - randf()),0)
			#main.get_node("Character/GunNode").recoilvel += randf() - randf()
			#main.get_node("Character/GunNode").recoilvelh += randf() - randf()
	
	if collray.is_colliding():
		var target_basis = Basis()
		target_basis.y = collray.get_collision_normal()
		target_basis.x = target_basis.y.cross(global_transform.basis.z).normalized()
		target_basis.z = target_basis.x.cross(target_basis.y).normalized()
		
		global_transform.basis = target_basis.scaled(scale)
	
	#IF RAT IS A TENNIS RAT, PARRY PROJECTILES
	if rattype == "Tennis":
		var parts = main.get_children(true)
		for part in parts:
			if part.name.begins_with("projectile") and part.freeze == false:
				var dist = part.position.distance_to(position)
				if dist < 8 and lastability > 5:
					lastability = 0
					$ParrySound.play(0.1)
					part.linear_velocity = (playerpos - position).normalized() * 15
	
	#IF RAT IS A THROWER RAT, THROW THINGS
	if rattype == "Thrower":
		if lastability > 5:
			lastability = 0
			var dir = position.direction_to(playerpos)
			dir.y = 0.0
			var angle = get_3d_launch_angles(position + dir.normalized() * 3, playerpos + Vector3(0,2,0), 20)
			if angle != []:
				var projectile = load("res://projectile.tscn").instantiate()
				main.add_child(projectile, true)
				projectile.position = position + dir.normalized() * 3
				var axis = Vector3.UP.cross(dir).normalized()
				var launch_velocity = dir.rotated(axis, angle[0]) * 20
				projectile.linear_velocity = launch_velocity
