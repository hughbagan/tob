extends Node2D

onready var player = $Entities/Player

func _ready():
	player.hp = Global.player_hp
	player.tilemap = $Walls
	$Entities/Enemy.tilemap = $Walls
	$Entities/Enemy.player = player
	player.connect("new_hp", self, "_on_player_hp_changed")
	player.connect("player_die", self, "_on_player_die")

	$GUI/RedRect.show()
	var tween = get_tree().create_tween()
	tween.tween_property($GUI/RedRect, "color:a", 0.0, 1.0)
	yield(tween, "finished")
	$GUI/RedRect.hide()


func _on_exit_reached():
	Global.player_hp = 100.0
	MusicMan.StepsSound()
	$GUI/RedRect.show()
	var tween = get_tree().create_tween()
	tween.tween_property($GUI/RedRect, "color:a", 1.0, 1.0)
	yield(tween, "finished")
	get_tree().change_scene("res://scenes/Level.tscn")


func _on_player_hp_changed(new_hp:float) -> void:
	$GUI/BloodBar.value = new_hp


func _on_player_die():
	# Fade out
	$Entities.pause_mode = PAUSE_MODE_STOP
	$GUI/RedRect.show()
	var tween = get_tree().create_tween()
	tween.tween_property($GUI/RedRect, "color:a", 1.0, 1.0)
	yield(tween, "finished")
	$GUI/DeathLabel.show()
	yield(get_tree().create_timer(5.0), "timeout")
	var tween2 = get_tree().create_tween()
	tween2.tween_property($GUI/DeathLabel, "color:a", 0.0, 1.0)
	yield(tween2, "finished")
	get_tree().change_scene("res://scenes/MainMenu.tscn")
