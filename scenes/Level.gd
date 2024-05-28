class_name Level extends Node2D

const LEVEL_WALL_TILE_ID:int = 24
const PLAYER_SCENE:PackedScene = preload("res://scenes/Player.tscn")
onready var generator = $WFCGenerator
onready var target_tilemap:TileMap = $WFCGenerator/Target
onready var envelope_tilemap:TileMap = $WFCGenerator/Target/Envelope
onready var camera:Camera2D = $WFCGenerator/Target/Camera2D
var player:Player


func _on_WFCGenerator_OnDone():
	var width:int = generator.H+1
	var height:int = generator.V+1

	# encase the level in an invisible wall
	# envelope_tilemap.position = -target_tilemap.cell_size
	# for y in range(height):
	# 	for x in range(width):
	# 		if (x==0 or y==0) or (x==width-1 or y==height-1):
	# 			envelope_tilemap.set_cell(x, y, LEVEL_WALL_TILE_ID)

	# TODO: spawn entities to replace tiles

	# Deploy the player
	player = PLAYER_SCENE.instance()
	player.tilemap = target_tilemap
	player.global_position = target_tilemap.map_to_world(Vector2(width/2, height/2))-target_tilemap.cell_size/2
	add_child(player)
	camera.position = target_tilemap.get_used_rect().size*target_tilemap.cell_size*0.5
