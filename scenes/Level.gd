class_name Level extends Node2D

const LEVEL_WALL_TILE_ID:int = 24
const LEVEL_ENEMY_TILE_ID:int = 22
const PLAYER_SCENE:PackedScene = preload("res://scenes/Player.tscn")
const ENEMY_SCENE:PackedScene = preload("res://scenes/Enemy.tscn")
onready var generator:Node2D = $WFCGenerator
onready var target_tilemap:TileMap = $WFCGenerator/Target
onready var envelope_tilemap:TileMap = $WFCGenerator/Target/Envelope
onready var camera:Camera2D = $WFCGenerator/Target/Camera2D


func _on_WFCGenerator_OnDone():
	var width:int = generator.H+1
	var height:int = generator.V+1

	# encase the level in an invisible wall
	# envelope_tilemap.position = -target_tilemap.cell_size
	# for y in range(height):
	# 	for x in range(width):
	# 		if (x==0 or y==0) or (x==width-1 or y==height-1):
	# 			envelope_tilemap.set_cell(x, y, LEVEL_WALL_TILE_ID)

	# Spawn entities to replace tiles
	for y in range(height):
		for x in range(width):
			print(x, " ", y, " ", target_tilemap.get_cell(x,y))
			if target_tilemap.get_cell(x, y) == LEVEL_ENEMY_TILE_ID:
				var enemy = ENEMY_SCENE.instance()
				enemy.global_position = place_centered_tile(Vector2(x,y))
				add_child(enemy)

	# Deploy the player
	var player = PLAYER_SCENE.instance()
	player.tilemap = target_tilemap
	player.level = self
	var testpos = Vector2(width/2, height/2)
	while target_tilemap.get_cellv(testpos) == LEVEL_WALL_TILE_ID:
		var flip = randf()
		if flip <= 0.25:
			testpos.x += 1
		elif flip <= 0.5:
			testpos.x -= 1
		elif flip <= 0.75:
			testpos.y += 1
		elif flip <= 1.0:
			testpos.y -= 1
	player.global_position = place_centered_tile(testpos)
	add_child(player)
	camera.position = target_tilemap.get_used_rect().size*target_tilemap.cell_size*0.5


func place_centered_tile(pos:Vector2) -> Vector2:
	return target_tilemap.map_to_world(pos)+target_tilemap.cell_size/2
