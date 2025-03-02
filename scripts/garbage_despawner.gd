extends Node2D

@export var distanceCheckTimeout = 1.0
@export var garbageTruck: Node2D

var distanceCheckTimer = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if distanceCheckTimer > distanceCheckTimeout:
		checkDespawnables()
		distanceCheckTimer = 0.0
	distanceCheckTimer += delta

func checkDespawnables():
	var despawnX = garbageTruck.global_position.x
	var children = get_children()
	# despawn garbage bags and garbage gropup when all contents are despawned 
	var isJustEmptyBags = true
	for child in children:
		if(child.is_in_group("garbage_bag")): 
			continue	
		isJustEmptyBags = false
		var rb = child.get_children().filter(func(c): return c is RigidBody2D).front()
		if rb.global_position.x < despawnX:
			#print("despawn triggered")
			#print("despawnX is ", despawnX)
			settleScoreAndDespawn(child)
	if isJustEmptyBags:
		queue_free()
		

func settleScoreAndDespawn(node: Node2D):
	var points = extractPoints(node)
	print("extracted ", points, " points from ", node.name)
	if points:
		ScoreManager.settle_score(points)
	node.queue_free()
	#print("settled score and despawned ", node.name)


func extractPoints(node: Node2D) -> int:
	for child in node.get_children():
		var scoreLabel: ScoreLabel = null
		var filteredChildren = child.get_children().filter(func(c): return c is ScoreLabel)
		if filteredChildren.size():
			scoreLabel = filteredChildren.front()
		# there may be hidden 0 labels
		if scoreLabel and scoreLabel.score > 0:
			return scoreLabel.score
	return 0
