extends Node2D

@export var houseSpawner: HouseSpawner
@export var garbagePrefabs: Array[PackedScene]
@export var distanceFromHouse = 1000.0
@export var camera: FollowCamera

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	houseSpawner.house_spawned_right.connect(spawnAroundHouse)
	pass # Replace with function body.
	
func spawnAroundHouse(x: float):
	print("spawn 2 garbage piles")
	spawn(x + distanceFromHouse)
	spawn(x - distanceFromHouse)

func spawn(x: float):
	await get_tree().create_timer(1).timeout # make spawning async
	var instance: Node2D
	instance = garbagePrefabs.pick_random().instantiate()
	instance.position.x = x
	instance.set_physics_process(false) # Disable physics initially
	instance.set_process(false)
	add_child(instance)
	instance.camera = camera
	await get_tree().create_timer(0.1).timeout # Short delay
	instance.set_physics_process(true)
	instance.set_process(true)
