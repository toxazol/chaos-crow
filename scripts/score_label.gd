extends Label

class_name ScoreLabel

var timer = 0.0
var timeOut = 0.0
var score = 0

func setScore(points: int, timeout: float):
	score = points
	text = str(score)
	timeOut = timeout
	timer = 0.0
	visible = true
	
	
func resetScore():
	#print("reset score for ", get_parent().get_parent().name)
	score = 0
	text = str(score)
	visible = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not visible:
		return
		
	if timer >= timeOut:
		resetScore()
	else:
		timer += delta
	var parent: Node2D = get_parent()
	rotation = -parent.rotation
