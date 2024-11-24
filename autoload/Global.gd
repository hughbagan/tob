extends Node

const EXIT_SCENE:PackedScene = preload("res://scenes/entities/Exit.tscn")
const PLAYER_SCENE:PackedScene = preload("res://scenes/entities/Player.tscn")
const ENEMY_SCENE:PackedScene = preload("res://scenes/entities/Enemy.tscn")
const ENEMY_TANK_SCENE:PackedScene = preload("res://scenes/entities/TankEnemy.tscn")
const ENEMY_SHOOT_SCENE:PackedScene = preload("res://scenes/entities/ShootEnemy.tscn")
const LAMP_SCENE:PackedScene = preload("res://scenes/entities/Lamp.tscn")
const LEVEL_FLOOR_TILE_ID:int = 0
const LEVEL_WALL_TILE_ID:int = 1
const LEVEL_ENEMY_TILE_ID:int = 2
const LEVEL_LAMP_TILE_ID:int = 3
const TILE_ID:Dictionary = {
	# atlas coords:		tile ID
	Vector2i(-1, -1):	-1, # EMPTY
	Vector2i(8, 5):		LEVEL_FLOOR_TILE_ID,
	Vector2i(0, 13):	LEVEL_WALL_TILE_ID,
	Vector2i(29, 6):	LEVEL_ENEMY_TILE_ID,
	Vector2i(5, 15):	LEVEL_ENEMY_TILE_ID
}
const PLAYER_MAX_HP:float = 100.0
var player_hp:float = PLAYER_MAX_HP


func get_cell_id(map:TileMapLayer, coords:Vector2i) -> int:
	return TILE_ID[map.get_cell_atlas_coords(coords)]


func set_cell_id(map:TileMapLayer, coords:Vector2, tileID:int) -> void:
	for atlas_coord in TILE_ID.keys():
		if TILE_ID[atlas_coord] == tileID:
			map.set_cell(coords, 0, atlas_coord)
			return
	assert(false, "Didn't find {0} in TILE_ID" % tileID)
