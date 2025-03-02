extends Node2D

@export var crow: Node2D
@export var speed = 10.0
@export var minDistFromPlayer = 2000.0
@export var teleportCheckTimeout = 3.0

var teleportCheckTimer = 0.0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$InnerCircle/AnimatedInnerCircle.play("default")
	$OuterCircle/AnimatedOuterCircle.play("default")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position.x += speed * delta
	
	if teleportCheckTimer > teleportCheckTimeout:
		var dist = abs(crow.position.x - position.x)
		if dist > minDistFromPlayer:
			position.x = crow.position.x - minDistFromPlayer
			print("teleported garbage car closer to player")
		teleportCheckTimer = 0.0
	teleportCheckTimer += delta


func _on_inner_circle_entered(body: Node2D) -> void:
	print_rich("[color=red]death zone entered[/color]")


func _on_outer_circle_entered(body: Node2D) -> void:
	print_rich("[color=orange]danger zone entered[/color]")
