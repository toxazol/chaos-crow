extends CharacterBody2D


@export var friction = 20.0
@export var hopVelocity = Vector2(500.0, 200.0)
@export var flyVelocity = Vector2(700.0, 500.0)
@export var takeOffTime = 0.1
@export var maxNeckLen = 55
@export var maxNeckHoldTimeout = 0.5
@export var landingAirResist = 100.0

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var neck: Line2D = $Neck
@onready var head_sprite: Sprite2D = $HeadSprite
@onready var neck_base: Node2D = $HeadSprite/NeckBase
@onready var beak_zone: Area2D = $BeakZone
@onready var flap: AudioStreamPlayer = $Flap
@onready var landing_ray_cast: RayCast2D = $LandingRayCast


enum CrowState {
	Idling,
	Hopping,
	Flying,
	TakingOff,
	Landing
}
var curState: CrowState = CrowState.Idling
var stateChangeTimer = 0.0

var isFlying = false
var wasFlying = false
var isTakeOff = false
var isLanding = false
var thingInBeak: Node2D = null
var initialHeadTransform
var initialNeckBasePostion
var direction = 0.0
var prevDirection = 1.0
var takeOffTimer = 0.0
var holdTimer = 0.0

func _ready():
	initialHeadTransform = head_sprite.transform
	initialNeckBasePostion = neck.points[1]


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
		
	# landing check
	isLanding = false
	if isFlying and velocity.y > 0: # heading downwards
		#var dir = landing_ray_cast.target_position
		#var dirLen = dir.length()
		if landing_ray_cast.is_colliding():
			# add air resistance
			velocity.y -= pow(velocity.y, 2) * 0.005 * delta
			isLanding = true
	# Get the input direction and handle the movement/deceleration.
	direction = Input.get_axis("left", "right")
	if (direction and is_on_floor()) or isFlying:
		if is_on_floor():
			velocity.y = -hopVelocity.y
			velocity.x = direction * hopVelocity.x
		if Input.is_action_pressed("fly"):
			velocity.y = -flyVelocity.y
		if isFlying:
			velocity.x = direction * flyVelocity.x
	else: # deceleration/friction
		velocity.x = move_toward(velocity.x, 0, friction)

	move_and_slide()


func _process(delta: float):
	
	#match curState:
		#CrowState.Idling:
			#...
		#CrowState.TakingOff:
			#takeOffTimer -= delta
			#if takeOffTimer <= 0.0:
				#changeState()
			
	
	# random flapping sounds
	if isFlying and not flap.is_playing():
		flap.play()
	if not isFlying:
		flap.stop()
		
	if thingInBeak:
		# var vecToObj = thingInBeak.global_position - beak_zone.global_position
		# head_sprite.rotation = head_sprite.position.angle_to(vecToObj)
		head_sprite.global_position = thingInBeak.global_position
		neck.points[1] = neck_base.global_position - neck.global_position
		neck.points[1].x *= sign(scale.y) # for some reason scale.y = -1 (not x) when we are flipped
	
	# animation
	if isTakeOff:
		if takeOffTimer < takeOffTime:
			takeOffTimer += delta
		else:
			isTakeOff = false
			takeOffTimer = 0.0
		
	if isTakeOff:
		animated_sprite_2d.play("takeoff")
	elif isLanding:
		print_rich("[color=cyan]animating landing[/color]")
		animated_sprite_2d.play("landing")
	elif isFlying:
		animated_sprite_2d.play("fly")
	elif direction:
		animated_sprite_2d.play("hop")
	else:
		animated_sprite_2d.play("idle")

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
	return thingInBeak and neck.points[1].distance_squared_to(neck.points[0]) > maxNeckLen*maxNeckLen


func peck():
	if thingInBeak:
		thingInBeak.call("drop")
		thingInBeak = null
		head_sprite.transform = initialHeadTransform
		neck.points[1] = initialNeckBasePostion
		return

	var bodies = beak_zone.get_overlapping_bodies()
	var nearest: Node2D = null
	var nearestDistSq: float
	for body in bodies:
		if body.has_method("stick"):
			if has_overlapping_trash_bags(body):
				continue
			var distSq = body.global_position.distance_squared_to(beak_zone.global_position)
			if !nearest or distSq < nearestDistSq:
				nearest = body
				nearestDistSq = distSq
	if nearest:
		nearest.call("stick", beak_zone)
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
