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
	var tween = $GUI.create_tween()
	tween.tween_property($GUI/RedRect, "color:a", 0.0, 1.0)
	yield(tween, "finished")
	$GUI/RedRect.hide()


func _on_exit_reached():
	get_tree().paused = true
	Global.player_hp = Global.PLAYER_MAX_HP
	MusicMan.steps_sound()
	$GUI/RedRect.show()
	var tween = $GUI.create_tween()
	tween.tween_property($GUI/RedRect, "color:a", 1.0, 1.0)
	yield(tween, "finished")
	get_tree().paused = false
	get_tree().change_scene("res://scenes/Level.tscn")


func _on_player_hp_changed(new_hp:float) -> void:
	$GUI/BloodBar.value = new_hp


func _on_player_die():
	# Fade out
	get_tree().paused = true
	$GUI/RedRect.show()
	MusicMan.level(false, 1)
	MusicMan.player_dead = true
	var tween = $GUI.create_tween()
	tween.tween_property($GUI/RedRect, "color:a", 1.0, 1.0)
	yield(tween, "finished")
	$GUI/DeathLabel.show()
	yield(get_tree().create_timer(5.0), "timeout")
	get_tree().paused = false
	get_tree().change_scene("res://scenes/MainMenu.tscn")
