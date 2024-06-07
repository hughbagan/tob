extends Node2D


func _ready():
	$Entities/Player.tilemap = $Walls
	$Entities/Enemy.tilemap = $Walls
	$Entities/Enemy.player = $Entities/Player

	$GUI/RedRect.show()
	var tween = get_tree().create_tween()
	tween.tween_property($GUI/RedRect, "color:a", 0.0, 1.0)
	yield(tween, "finished")
	$GUI/RedRect.hide()


func _on_exit_reached():
	MusicMan.StepsSound()
	$GUI/RedRect.show()
	var tween = get_tree().create_tween()
	tween.tween_property($GUI/RedRect, "color:a", 1.0, 1.0)
	yield(tween, "finished")
	get_tree().change_scene("res://scenes/Level.tscn")
