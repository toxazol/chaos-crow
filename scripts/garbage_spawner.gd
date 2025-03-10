extends Node2D

@export var houseSpawner: HouseSpawner
@export var garbagePrefabs: Array[PackedScene]
@export var distanceFromHouse := 1000.0
@export var garbageTruck: Node2D

#var garbagePrefab = preload("res://scenes/garbage_1.tscn")
#
#@export var pool_size: int = 10
#var pool: Array[Node2D] = []

func _ready() -> void:
	houseSpawner.house_spawned_right.connect(spawnAroundHouse)
	# Preload objects
	#for _i in range(pool_size):
		#var instance = garbagePrefab.instantiate()
		#instance.set_physics_process(false)
		#instance.set_process(false)
		#
		#switchGarbagePhysics(instance, false)
#
		#instance.camera = camera
		#instance.visible = false
		#add_child(instance) # Add to the scene but keep it disabled
		#pool.append(instance)
		
#func get_instance() -> Node2D:
	#if pool.is_empty():
		#push_error("no more garbage in pool")
		#return null
		#
	#for obj in pool:
		#if is_instance_valid(obj) and !obj.visible:  # Find an inactive object
			#obj.visible = true
			#switchGarbagePhysics(obj, true)
			#return obj
#
	#push_error("no more invisible garbage in pool")
	#return null

func spawnAroundHouse(x: float) -> void:
	#print("spawn 2 garbage piles")
	await get_tree().create_timer(1).timeout # don't spawn at the same time as house spawns
	spawn(x + distanceFromHouse)
	await get_tree().create_timer(1).timeout # make spawning async
	spawn(x - distanceFromHouse)

#func spawn(x: float):
	#var instance = get_instance()
	#if instance:
		##instance.camera = camera
		#instance.position.x = x

func spawn(x: float) -> void:
	var instance: Node2D
	instance = garbagePrefabs.pick_random().instantiate()
	#instance = garbagePrefab.instantiate()
	instance.set_physics_process(false) # Disable physics initially
	instance.set_process(false)
	call_deferred("add_child", instance)  # Ensure safe addition to the scene
	instance.garbageTruck = garbageTruck
	instance.position.x = x
	await get_tree().process_frame  # Wait for the next frame
	instance.set_physics_process(true)
	instance.set_process(true)
	
func switchGarbagePhysics(node: Node2D, on: bool) -> void:
	node.set_physics_process(on)
	node.set_process(on)
	for child in node.get_children():
		for b in child.get_children():
			if b is RigidBody2D:
				b.freeze = !on  # Completely switch physics updates
	
