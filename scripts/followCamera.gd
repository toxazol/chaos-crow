extends Camera2D

class_name FollowCamera

@export var followTarget: Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position = followTarget.global_position


func get_viewport_left_border():
	return position.x - get_viewport_rect().size.x/2

func get_viewport_right_border():
	return position.x + get_viewport_rect().size.x/2

func get_viewport_upper_border():
	return position.y - get_viewport_rect().size.y/2

func get_viewport_bottom_border():
	return position.y + get_viewport_rect().size.y/2
