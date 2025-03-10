extends StaticBody2D

@export var crow: Node2D
@export var speed := 10.0
@export var minDistFromPlayer := 2000.0
@export var teleportCheckTimeout := 3.0
@export var parkStopZone := 1000.0
@export var park: Node2D

var teleportCheckTimer := 0.0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$SoundCircle/AnimatedInnerCircle.play("default")
	$AnimationPlayer.play("wheels")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if(position.x + parkStopZone > park.global_position.x):
		$AnimationPlayer.stop()
		return
	position.x += speed * delta
	
	if teleportCheckTimer > teleportCheckTimeout:
		var dist: float = abs(crow.position.x - position.x)
		if dist > minDistFromPlayer:
			position.x = crow.position.x - minDistFromPlayer
			#print("teleported garbage car closer to player")
		teleportCheckTimer = 0.0
	teleportCheckTimer += delta
