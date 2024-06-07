extends Node2D


func _ready():
	$Entities/Player.tilemap = $Walls
	$Entities/Enemy.tilemap = $Walls
	$Entities/Enemy.player = $Entities/Player


func _on_exit_reached():
	get_tree().change_scene("res://scenes/Level.tscn")
