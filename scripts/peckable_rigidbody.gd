@tool
extends SoftBody2DRigidBody

var SPEED : float = 400
var DAMP : float = 0.1

var holdingThing: Node2D = null
# var isHighlighted = false

# func _draw():
# 	if isHighlighted:
# 		draw_circle(Vector2(), 10, Color.WHITE)

# func highlight():
# 	isHighlighted = !isHighlighted
# 	queue_redraw()

func stick(to: Node2D):
	holdingThing = to

func drop():
	holdingThing = null

func _physics_process(delta):

	if holdingThing:
		var dir = (holdingThing.global_position - global_position - DAMP * linear_velocity * delta)
		var length = dir.length()
		dir /= length
		length /= mass
		if length > SPEED:
			length = SPEED;
		if length < 1:
			length = 1;
		apply_central_impulse(dir * length)
