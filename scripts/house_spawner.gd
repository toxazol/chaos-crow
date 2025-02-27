extends Node2D

@export var housePrefabs: Array[PackedScene]
@export var minGap = 200
@export var maxGap = 1000
@export var camera: FollowCamera

## add both if any spawned manualy 
@export var leftMost: Node2D
@export var rightMost: Node2D

func _ready() -> void:
	if !rightMost and !leftMost:
		var instance = spawn(global_position)
		leftMost = instance
		rightMost = instance
		print("spawned house at spawner coords")


func _process(delta: float) -> void:
	var rBorder = camera.get_viewport_right_border()
	var lBorder = camera.get_viewport_left_border()

	if rBorder > rightMost.global_position.x:
		var pos = global_position
		pos.x = rBorder + randf_range(minGap, maxGap)
		rightMost = spawn(pos)
		print("spawned house to the right")

	if lBorder < leftMost.global_position.x:
		var pos = global_position
		pos.x = lBorder - randf_range(minGap, maxGap)
		leftMost = spawn(pos)
		print("spawned house to the left")


func spawn(pos: Vector2) -> Node2D:
	var instance: Node2D
	instance = housePrefabs.pick_random().instantiate()
	instance.position = pos - global_position
	if randf() < 0.5: # 50% chance that house will be flipped
		instance.scale.x *= -1
	add_child(instance)
	return instance
