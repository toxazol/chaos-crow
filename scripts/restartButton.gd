extends Button


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_visible_in_tree() and Input.is_action_just_pressed("ui_accept"):
		_on_pressed()


func _on_pressed() -> void:
	if get_tree():
		get_tree().change_scene_to_file("res://scenes/level.tscn")
