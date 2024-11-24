class_name Exit extends Area2D

signal exit_reached

func _on_Exit_body_entered(body:Node):
	if body is Player:
		# Go to next level
		emit_signal("exit_reached")
