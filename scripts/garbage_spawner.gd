extends Node2D

@export var houseSpawner: HouseSpawner
@export var garbagePrefabs: Array[PackedScene]
@export var distanceFromHouse = 1000.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	houseSpawner.house_spawned_right.connect(spawnAroundHouse)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func spawnAroundHouse(x: float):
	spawn(x + distanceFromHouse)
	spawn(x - distanceFromHouse)

func spawn(x: float):
	var instance: Node2D
	instance = garbagePrefabs.pick_random().instantiate()
	instance.position.x = x
	add_child(instance)
