@tool
extends SoftBody2DRigidBody

var SPEED : float = 400
var DAMP : float = 0.1
var RIP_TIMEOUT: float = 1.0

var holdingThing: Node2D = null

func stick(to: Node2D):
	holdingThing = to
	toggleRipping(true)

func drop():
	holdingThing = null
	await get_tree().create_timer(RIP_TIMEOUT).timeout
	toggleRipping(false)
	
func toggleRipping(isOn: bool):
	var softBody = get_parent()
	if softBody.has_method("toggle_ripping"):
		softBody.call("toggle_ripping", isOn)
		print("toggle ripping")

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
