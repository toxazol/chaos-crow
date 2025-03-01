extends Area2D

@export var pointsForContact = 1
@export var countUpdateTimeout = 0.3
@export var scoreLabel: PackedScene

var countUpdateTimer = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	countUpdateTimer += delta
	if countUpdateTimer >= countUpdateTimeout:
		var contactCount = countParents(get_overlapping_bodies())
		#print(contactCount)
		ScoreManager.update_score(contactCount * pointsForContact)
		countUpdateTimer = 0.0

func countParents(nodes: Array[Node2D]):
	var countedSet := {}
	for node in nodes:
		var parent = node.get_parent()
		if !parent:
			print_debug("parent not found")
			continue
		var id = parent.get_instance_id()
		if !countedSet.get(id):
			countedSet[id] = id
			updateScoreLabel(node)
	return countedSet.size()

func updateScoreLabel(node: Node2D):
	var label: ScoreLabel = node.get_children().filter(func(c): return c is ScoreLabel).front()
	if !label:
		label = scoreLabel.instantiate()
		node.add_child(label)
	label.setScore(pointsForContact, countUpdateTimeout)
