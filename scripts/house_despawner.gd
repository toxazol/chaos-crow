extends Node2D

@export var distanceCheckTimeout = 1.0
@export var despawnLeftDistance = 3000.0
@export var camera: FollowCamera

var distanceCheckTimer = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if distanceCheckTimer > distanceCheckTimeout:
		despawnIfFar()
		distanceCheckTimer = 0.0
	distanceCheckTimer += delta

func despawnIfFar():
	var despawnX = camera.get_viewport_left_border() - despawnLeftDistance
	if global_position.x < despawnX:
		print("returned house back to pool")
		self.hide()
		self.process_mode = Node.PROCESS_MODE_DISABLED
