extends CharacterBody2D


@export var speed = 500.0
@export var friction = 20.0
@export var hopVelocity = 200.0
@export var flyVelocity = 500.0
@export var takeOffTime = 0.1
@export var maxNeckLen = 55
@export var maxNeckHoldTimeout = 0.5

var isFlying = false
var wasFlying = false
var isTakeOff = false
var thingInBeak: Node2D = null
var initialHeadTransform
var initialNeckBasePostion
var direction = 0.0
var prevDirection = 1.0
var takeOffTimer = 0.0
var holdTimer = 0.0

func _ready():
	initialHeadTransform = $HeadSprite.transform
	initialNeckBasePostion = $Neck.points[1]


func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("peck"):
		peck()
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		wasFlying = isFlying
		isFlying = false
	if Input.is_action_pressed("fly"):
		wasFlying = isFlying
		isFlying = true
	if isFlying and not wasFlying:
		isTakeOff = true

	# Get the input direction and handle the movement/deceleration.
	direction = Input.get_axis("left", "right")
	if (direction and is_on_floor()) or isFlying:
		velocity.x = direction * speed
		if is_on_floor():
			velocity.y = -hopVelocity 
		if Input.is_action_pressed("fly"):
			velocity.y = -flyVelocity
	else: # deceleration/friction
		velocity.x = move_toward(velocity.x, 0, friction)

	move_and_slide()


func _process(delta: float):
	if thingInBeak:
		# var vecToObj = thingInBeak.global_position - $BeakZone.global_position
		# $HeadSprite.rotation = $HeadSprite.position.angle_to(vecToObj)
		$HeadSprite.global_position = thingInBeak.global_position
		$Neck.points[1] = $HeadSprite/NeckBase.global_position - $Neck.global_position
		$Neck.points[1].x *= sign(scale.y) # for some reason scale.y = -1 (not x) when we are flipped
	
	# animation
	if isTakeOff:
		if takeOffTimer < takeOffTime:
			takeOffTimer += delta
		else:
			isTakeOff = false
			takeOffTimer = 0.0
		
	if isTakeOff:
		$AnimatedSprite2D.play("takeoff")
	elif isFlying:
		$AnimatedSprite2D.play("fly")
	else:
		$AnimatedSprite2D.play("idle")

	# sprites flipping
	if direction && direction != prevDirection:
		prevDirection = direction
		scale.x *= -1

	if isNeckTooLong():
		holdTimer += delta
		if holdTimer > maxNeckHoldTimeout:
			peck()
	if holdTimer > maxNeckHoldTimeout:
		holdTimer = 0.0


func isNeckTooLong() -> bool:
	return thingInBeak and $Neck.points[1].distance_squared_to($Neck.points[0]) > maxNeckLen*maxNeckLen


func peck():
	if thingInBeak:
		thingInBeak.call("drop")
		thingInBeak = null
		$HeadSprite.transform = initialHeadTransform
		$Neck.points[1] = initialNeckBasePostion
		return

	var bodies = $BeakZone.get_overlapping_bodies()
	var nearest: Node2D = null
	var nearestDistSq: float
	for body in bodies:
		if body.has_method("stick"):
			if has_overlapping_trash_bags(body):
				continue
			var distSq = body.global_position.distance_squared_to($BeakZone.global_position)
			if !nearest or distSq < nearestDistSq:
				nearest = body
				nearestDistSq = distSq
	if nearest:
		nearest.call("stick", $BeakZone)
		thingInBeak = nearest


func has_overlapping_trash_bags(garbage: Node2D):
	if !garbage.get_parent().is_in_group("garbage"):
		return false
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsShapeQueryParameters2D.new()
	var collider = garbage.get_children().filter(func(c): return c is CollisionShape2D).front()
	query.set_shape(collider.shape)				# Use garbage shape
	query.transform = garbage.global_transform	# Check at garbage's position
	query.collision_mask = 1 << 2				# Only detect layer 3 (trash bag internals)
	var results = space_state.intersect_shape(query)
	return results.size() > 0
