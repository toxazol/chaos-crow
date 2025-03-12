extends Node2D


func _input(event: InputEvent) -> void:
	if (event is InputEventKey and event.pressed) or (event is InputEventScreenTouch and event.pressed):
		if get_tree():
			get_tree().change_scene_to_file("res://scenes/level.tscn")
