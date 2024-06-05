class_name Level extends Node2D

const LEVEL_FLOOR_TILE_ID:int = 0
const LEVEL_WALL_TILE_ID:int = 24
const LEVEL_ENEMY_TILE_ID:int = 22
const LEVEL_LAMP_TILE_ID:int = 23
const EXIT_SCENE:PackedScene = preload("res://scenes/Exit.tscn")
const PLAYER_SCENE:PackedScene = preload("res://scenes/Player.tscn")
const ENEMY_SCENE:PackedScene = preload("res://scenes/Enemy.tscn")
const LAMP_SCENE:PackedScene = preload("res://scenes/Lamp.tscn")
onready var generator:Node2D = $WFCGenerator
onready var target_tilemap:TileMap = $WFCGenerator/Target
onready var envelope_tilemap:TileMap = $WFCGenerator/Envelope
onready var camera:Camera2D = $WFCGenerator/Target/Camera2D
onready var entities:Node2D = $Entities
var width:int
var height:int


func _on_WFCGenerator_OnDone():
	width = generator.H
	height = generator.V
	print(width, " ", height)
	var corners = [Vector2(0, 0), Vector2(width-1, 0), Vector2(0, height-1), Vector2(width-1, height-1)]

	# encase the level in an invisible wall
	envelope_tilemap.position = -target_tilemap.cell_size
	# for y in range(height):
	# 	for x in range(width):
	# 		if (x==0 or y==0) or (x==width-1 or y==height-1):
	# 			envelope_tilemap.set_cell(x, y, LEVEL_WALL_TILE_ID)

	# Spawn entities to replace tiles
	for y in range(height):
		for x in range(width):
			var tile:int = target_tilemap.get_cell(x, y)
			if tile == LEVEL_ENEMY_TILE_ID:
				envelope_tilemap.set_cell(x+1, y+1, LEVEL_FLOOR_TILE_ID)
				var enemy = ENEMY_SCENE.instance()
				enemy.global_position = place_centered_tile(Vector2(x, y))
				entities.add_child(enemy)
			if tile == LEVEL_LAMP_TILE_ID:
				envelope_tilemap.set_cell(x+1, y+1, LEVEL_FLOOR_TILE_ID)
				var lamp = LAMP_SCENE.instance()
				lamp.global_position = place_centered_tile(Vector2(x, y))
				entities.add_child(lamp)

	# Place the player
	var player = PLAYER_SCENE.instance()
	player.tilemap = target_tilemap
	player.level = self
	var player_corner = corners[randi() % corners.size()]
	player.global_position = place_adjacent_random_empty(player_corner)
	entities.add_child(player)

	# Place the exit in a different corner
	var exit = EXIT_SCENE.instance()
	exit.connect("exit_reached", self, "_on_exit_reached")
	var exit_corner = player_corner
	while exit_corner == player_corner:
		exit_corner = corners[randi() % corners.size()]
	exit.global_position = place_adjacent_random_empty(exit_corner)
	entities.add_child(exit)


	camera.position = target_tilemap.get_used_rect().size*target_tilemap.cell_size*0.5


func place_centered_tile(pos:Vector2) -> Vector2:
	# convert tilemap coords to global centered position
	return target_tilemap.map_to_world(pos)+target_tilemap.cell_size/2


func place_adjacent_random_empty(startpos:Vector2) -> Vector2:
	var pos:Vector2 = startpos
	while target_tilemap.get_cellv(pos) != LEVEL_FLOOR_TILE_ID:
		var flip = randf()
		if flip <= 0.25 and pos.x < width-1:
			pos.x += 1
		elif flip <= 0.5 and pos.x > 0:
			pos.x -= 1
		elif flip <= 0.75 and pos.y < height-1:
			pos.y += 1
		elif flip <= 1.0 and pos.y > 0:
			pos.y -= 1
	return place_centered_tile(pos)


func _on_exit_reached():
	# Advance the level
	for child in entities.get_children():
		child.queue_free()
	envelope_tilemap.clear()
	generator.OnButtonPressed()
