extends CharacterBody2D


@export var speed = 500.0
@export var friction = 20.0
@export var hopVelocity = -200.0

var isFlying = false

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_pressed("ui_up"):
		isFlying = true
	else:
		isFlying = false

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction and (is_on_floor() or isFlying):
		velocity.x = direction * speed
		velocity.y = hopVelocity #<-- works good for flying
		if direction > 0:
			$AnimatedSprite2D.flip_h = false
			$HeadSprite.flip_h = false
			$HeadSprite.position.x = abs($HeadSprite.position.x)
		else:
			$AnimatedSprite2D.flip_h = true
			$HeadSprite.flip_h = true
			$HeadSprite.position.x = -abs($HeadSprite.position.x)

	else: # deceleration/friction
		velocity.x = move_toward(velocity.x, 0, friction)


	move_and_slide()
