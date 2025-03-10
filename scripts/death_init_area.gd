extends Area2D

@export var deathTimeout := 3.0

var isDying := false
var deathTimer := 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if isDying:
		if deathTimer > deathTimeout:
			call_deferred("showGameOver")
		deathTimer += delta


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		print_rich("[color=red]you will die soon[/color]")
		isDying = true


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		print_rich("[color=green]you made it alive this time[/color]")
		isDying = false
		deathTimer = 0.0
	
func showGameOver() -> void:
	body_exited.disconnect(_on_body_exited)
	if get_tree():
		get_tree().change_scene_to_file("res://scenes/game_over.tscn")
