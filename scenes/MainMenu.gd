extends Control


func _ready() -> void:
	$Credits.hide()


func _on_PlayButton_pressed() -> void:
	$StepsSound.play()
	$RedRect.show()
	var tween = get_tree().create_tween()
	tween.tween_property($RedRect, "color:a", 1.0, 1.5)
	yield(tween, "finished")
	get_tree().change_scene("res://scenes/Tutorial.tscn")


func _on_InfoButton_pressed():
	$Credits.show()


func _on_BackButton_pressed():
	$Credits.hide()
