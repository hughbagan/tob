class_name Exit extends Area2D

signal exit_reached

func _on_Exit_body_entered(body:Node):
	if body.get_name() == "Player": # apparently Godot3 class refs are busted
		# Go to next level
		emit_signal("exit_reached")
