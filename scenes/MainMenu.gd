extends Control


func _ready() -> void:
	$Credits.hide()
	MusicMan.MainMenu(true, 2)


func _on_PlayButton_pressed() -> void:
	MusicMan.StepsSound()
	$RedRect.show()
	var tween = get_tree().create_tween()
	var tween_len = 1.5
	tween.tween_property($RedRect, "color:a", 1.0, tween_len)
	MusicMan.MainMenu(false, tween_len)
	yield(tween, "finished")
	get_tree().change_scene("res://scenes/Tutorial.tscn")


func _on_InfoButton_pressed():
	$Credits.show()
	MusicMan.MainMenu(false, 1)
	MusicMan.Credits(true, 1)


func _on_BackButton_pressed():
	$Credits.hide()
	MusicMan.Credits(false, 1)
	MusicMan.MainMenu(true, 1)
