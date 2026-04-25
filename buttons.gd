extends CanvasLayer

@export var currenttool: Node
@onready var main = get_tree().root.get_child(0)

var scorelife: float = 0.0
var scoreadd: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	scorelife += delta
	if $FeedScoreLabel.modulate.a > 0:
		if scorelife > 5:
			$FeedScoreLabel.modulate.a = move_toward($FeedScoreLabel.modulate.a, 0, delta*0.2)
	elif scoreadd > 0:
		scoreadd = 0
	
	if $Sideblack.modulate.a > 0:
		$Sideblack.modulate.a = move_toward($Sideblack.modulate.a, 0, delta*0.2)
	
	#display health
	var character = get_tree().root.get_child(0).find_child("Character")
	if character:
		$HealthBar.value = character.health
		
		#does player have gun?
		if currenttool:
			if currenttool.has_node("GunAnimate"):
				$Label.text = str(currenttool.ammo)
			else:
				$Label.text = "YES TOOL"
		else:
			$Label.text = "No Gun"
	$FPSLabel.text = "FPS: " + str(Engine.get_frames_per_second())
	$FeedScoreLabel.text = "+ " + str(scoreadd)


func _on_main_feed(message: String, color: Color = Color(1,1,1), _score: float = 0.0) -> void:
	for button in get_children():
		if button.name.begins_with("FeedLabel") and button.name != "FeedLabel":
			button.position.y += 20
	if _score > 0.0:
		$FeedScoreLabel.modulate.a = 1
		scorelife = 0
		scoreadd += _score
	if color == Color(1,0.5,0.5):
		main.get_node("Hitmarker").play()
	var clone = $FeedLabel.duplicate()
	add_child(clone, true)
	clone.text = message
	clone.modulate = color
	clone.label_settings.outline_color = color * Color(1,1,1,0.5)
