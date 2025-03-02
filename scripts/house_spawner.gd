extends Node2D

class_name HouseSpawner

@export var housePrefabs: Array[PackedScene]
@export var minGap = 200
@export var maxGap = 1000
@export var camera: FollowCamera
@export var spawnTimeout = 1.0

@export var park: Node2D

## add both if any spawned manualy 
@export var leftMost: Node2D
@export var rightMost: Node2D

var spawnTimer = 0.0
var isStopSpawn = false

signal house_spawned_right

func _ready() -> void:
	if !rightMost and !leftMost:
		var instance = spawn(0.0)
		leftMost = instance
		rightMost = instance
		print("spawned house at spawner coords")


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
	var lBorder = camera.get_viewport_left_border()

	if rBorder > rightMost.global_position.x:
		var x = rBorder + randf_range(minGap, maxGap)
		rightMost = spawn(x)
		house_spawned_right.emit(x)
		print("spawned house to the right")

	if is_instance_valid(leftMost) and lBorder < leftMost.global_position.x:
		var x = lBorder - randf_range(minGap, maxGap)
		leftMost = spawn(x)
		print("spawned house to the left")


func spawn(x: float) -> Node2D:
	var instance: Node2D
	instance = housePrefabs.pick_random().instantiate()
	instance.position.x = x - global_position.x
	if randf() < 0.5: # 50% chance that house will be flipped
		instance.scale.x *= -1
	add_child(instance)
	instance.camera = camera
	return instance
