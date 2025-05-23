extends Area2D

@export var pointsForContact := 1
@export var countUpdateTimeout := 0.3
@export var scoreLabel: PackedScene
@export var labelColor: Color

var countUpdateTimer := 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	countUpdateTimer += delta
	if countUpdateTimer >= countUpdateTimeout:
		countParents(get_overlapping_bodies())
		#print(contactCount)
		#ScoreManager.update_score(contactCount * pointsForContact)
		countUpdateTimer = 0.0

func countParents(nodes: Array[Node2D]) -> void:
	var countedSet := {}
	for node in nodes:
		var parent := node.get_parent()
		if !parent:
			print_debug("parent not found")
			continue
		var id := parent.get_instance_id()
		if !countedSet.get(id):
			countedSet[id] = id
			updateScoreLabel(node)

func updateScoreLabel(node: Node2D) -> void:
	var label: ScoreLabel = null
	var filteredChildren := node.get_children().filter(
		func(c:Node)->bool: return c is ScoreLabel)
	if filteredChildren.size():
		label = filteredChildren.front()
		label.add_theme_color_override("font_color", labelColor)
	if !label:
		label = scoreLabel.instantiate()
		node.add_child(label)
	label.setScore(pointsForContact, countUpdateTimeout)
