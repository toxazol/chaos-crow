extends Node2D

class_name HouseSpawner

@export var housePrefabs: Array[PackedScene]
@export var minGap = 200
@export var maxGap = 1000
@export var camera: FollowCamera
@export var spawnTimeout = 1.0

@export var park: Node2D

## add if any spawned manualy 
@export var rightMost: Node2D

var spawnTimer = 0.0
var isStopSpawn = false

var pool: Array[Node2D] = []
@export var poolSize: int = 3

signal house_spawned_right

func _ready() -> void:
	populatePool()
	if !rightMost:
		var instance = spawn(0.0)
		rightMost = instance
		print("spawned house at spawner coords")

func populatePool():
	for i in range(poolSize):
		pool.append(prespawn(i))

func _physics_process(delta: float) -> void:
	if isStopSpawn or spawnTimer < spawnTimeout:
		spawnTimer += delta
		return
	else:
		spawnTimer = 0.0
		
	# stop spawning if park is close
	if rightMost.global_position.x + maxGap + 1000 > park.global_position.x:
		isStopSpawn = true 
	
	var rBorder = camera.get_viewport_right_border()

	if rBorder > rightMost.global_position.x:
		var x = rBorder + randf_range(minGap, maxGap)
		rightMost = spawn(x)
		house_spawned_right.emit(x)
		print("spawned house to the right")



func prespawn(i: int) -> Node2D:
	var instance: Node2D
	instance = housePrefabs[i % housePrefabs.size()].instantiate()
	add_child(instance)
	instance.camera = camera
	instance.hide()
	instance.process_mode = Node.PROCESS_MODE_DISABLED
	return instance
	
#func spawn(x: float) -> Node2D:
	#var instance: Node2D
	#instance = housePrefabs.pick_random().instantiate()
	#instance.position.x = x - global_position.x
	#if randf() < 0.5: # 50% chance that house will be flipped
		#instance.scale.x *= -1
	#add_child(instance)
	#instance.camera = camera
	#return instance

func spawn(x: float) -> Node2D:
	if pool.is_empty():
		print_rich("[color=red]house spawner. pool is empty[/color]")
		pool.append(prespawn(randi() % housePrefabs.size()))
		return spawn(x)
	var hiddenHouseIndeces: Array[int] = []
	for i in range(pool.size()):
		var obj: Node2D = pool[i]
		if not obj.visible:
			hiddenHouseIndeces.append(i)
	if hiddenHouseIndeces.is_empty():
		print_rich("[color=orange]house spawner. no available houses in pool[/color]")
		pool.append(prespawn(randi() % housePrefabs.size()))
		return spawn(x)
	var instance: Node2D
	instance = pool[hiddenHouseIndeces.pick_random()]
	instance.position.x = x - global_position.x
	if randf() < 0.5: # 50% chance that house will be flipped
		instance.scale.x *= -1
	instance.show()
	instance.process_mode = Node.PROCESS_MODE_INHERIT
	return instance
