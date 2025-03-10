extends Camera2D

class_name FollowCamera

@export var followTarget: Node2D
@export var rightWall: Node2D
@export var ceiling: Node2D
@export var maxZoom := Vector2(0.8, 0.8)
@export var minZoom := Vector2(0.3, 0.3)
@export var zoomSpeed := 0.5


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	limit_right = int(rightWall.global_position.x)
	limit_top = int(ceiling.global_position.y)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position = followTarget.global_position
	var targetZoom: Vector2
	if followTarget.isFlying:
		targetZoom = minZoom
	else:
		targetZoom = maxZoom
	zoom = zoom.lerp(targetZoom, zoomSpeed * delta)


func get_viewport_left_border() -> float:
	return position.x - get_viewport_rect().size.x/2

func get_viewport_right_border() -> float:
	return position.x + get_viewport_rect().size.x/2

func get_viewport_upper_border() -> float:
	return position.y - get_viewport_rect().size.y/2

func get_viewport_bottom_border() -> float:
	return position.y + get_viewport_rect().size.y/2
