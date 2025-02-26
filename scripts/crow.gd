extends CharacterBody2D


@export var speed = 500.0
@export var friction = 20.0
@export var hopVelocity = -200.0
@export var takeOffTime = 0.1

var isLookingLeft = false
var isFlying = false
var wasFlying = false
var isTakeOff = false
var thingInBeak: Node2D = null
var initialHeadTransform
var direction = 0.0
var prevDirection = 1.0
var takeOffTimer = 0.0

func _ready():
	initialHeadTransform = $HeadSprite.transform

func peck():
	if thingInBeak:
		thingInBeak.call("drop")
		thingInBeak = null
		$HeadSprite.transform = initialHeadTransform
		if isLookingLeft:
			$HeadSprite.position.x *= -1
		return

	var bodies = $BeakZone.get_overlapping_bodies()
	var nearest: Node2D = null
	var nearestDistSq: float
	for body in bodies:
		if body.has_method("stick"):
			var distSq = body.global_position.distance_squared_to($BeakZone.global_position)
			if !nearest or distSq < nearestDistSq:
				nearest = body
				nearestDistSq = distSq
	if nearest:
		nearest.call("stick", $BeakZone)
		thingInBeak = nearest

func _physics_process(delta: float) -> void:
	if thingInBeak:
		# var vecToObj = thingInBeak.global_position - $BeakZone.global_position
		# $HeadSprite.rotation = $HeadSprite.position.angle_to(vecToObj)
		$HeadSprite.global_position = thingInBeak.global_position
		$Neck.points[1] = $HeadSprite/NeckBase.global_position - $Neck.global_position

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
		if is_on_floor() or Input.is_action_pressed("fly"):
			velocity.y = hopVelocity # works good for flying
		if direction > 0:
			isLookingLeft = false
		elif direction < 0:
			isLookingLeft = true
	else: # deceleration/friction
		velocity.x = move_toward(velocity.x, 0, friction)

	move_and_slide()


func _process(delta: float):
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
		$AnimatedSprite2D.flip_h = !$AnimatedSprite2D.flip_h
		$HeadSprite.flip_h = !$HeadSprite.flip_h
		$HeadSprite.position.x *= -1
		$HeadSprite/NeckBase.position.x *= -1
		$BeakZone.position.x *= -1
		$Neck.position.x *= -1
		$Neck.points[1].x *= -1

	
