extends Control


func _on_PlayButton_pressed() -> void:
	$StepsSound.play()
	$RedRect.show()
	var tween = get_tree().create_tween()
	tween.tween_property($RedRect, "color:a", 1.0, 1.0)
	yield(tween, "finished")
	get_tree().change_scene("res://scenes/Tutorial.tscn")
