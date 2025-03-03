extends Node2D


func _input(event):
	if event is InputEventKey && event.pressed && get_tree():
		get_tree().change_scene_to_file("res://scenes/level.tscn")
