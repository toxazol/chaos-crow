extends StaticBody2D

@export var pointsForContact = 1
@export var countUpdateTimeout = 0.3

var countUpdateTimer = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	countUpdateTimer += delta
	if countUpdateTimer > countUpdateTimeout:
		var contactCount = countParents($TrashDetector.get_overlapping_bodies())
		#print(contactCount)
		ScoreManager.set_score(contactCount * pointsForContact)
		countUpdateTimer = 0.0

func countParents(nodes: Array[Node2D]):
	var countedSet := {}
	for node in nodes:
		var parent = node.get_parent()
		if !parent:
			print_debug("parent not found")
			continue
		var id = parent.get_instance_id()
		countedSet[id] = id
	return countedSet.size()
