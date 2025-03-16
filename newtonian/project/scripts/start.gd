extends Node2D

func _process(delta):
	if Input.is_action_pressed("start"):
		get_tree().change_scene_to_file("res://scenes/main.tscn")
