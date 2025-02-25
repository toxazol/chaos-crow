extends CharacterBody2D


@export var speed = 500.0
@export var friction = 20.0
@export var hopVelocity = -200.0

var isLookingLeft = false
var isFlying = false
var thingInBeak: Node2D = null
var initialHeadTransform

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

	if Input.is_action_just_pressed("peck"):
		peck()

	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		isFlying = false

	if Input.is_action_pressed("fly"):
		isFlying = true

	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis("left", "right")
	if (direction and is_on_floor()) or isFlying:
		velocity.x = direction * speed
		if is_on_floor() or Input.is_action_pressed("fly"):
			velocity.y = hopVelocity # works good for flying
		if direction > 0:
			isLookingLeft = false
			$AnimatedSprite2D.flip_h = false
			$HeadSprite.flip_h = false
			$HeadSprite.position.x = abs($HeadSprite.position.x)
			$HeadSprite.offset.x = -abs($HeadSprite.offset.x)
			$BeakZone.position.x = abs($BeakZone.position.x)
		elif direction < 0:
			isLookingLeft = true
			$AnimatedSprite2D.flip_h = true
			$HeadSprite.flip_h = true
			$HeadSprite.position.x = -abs($HeadSprite.position.x)
			$HeadSprite.offset.x = abs($HeadSprite.offset.x)
			$BeakZone.position.x = -abs($BeakZone.position.x)

	else: # deceleration/friction
		velocity.x = move_toward(velocity.x, 0, friction)


	# animation
	if isFlying:
		$AnimatedSprite2D.play("fly")
	else:
		$AnimatedSprite2D.play("idle")


	move_and_slide()
