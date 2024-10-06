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

enum NAV_TILES {
	NORTHWEST,
	NORTH,
	NORTHEAST,
	WEST,
	EMPTY,
	EAST,
	SOUTHEAST,
	SOUTH,
	SOUTHWEST,
	NORTHWEST_NARROW,
	NORTH_NARROW,
	NORTHEAST_NARROW,
	WEST_NARROW,
	EMPTY_NARROW,
	EAST_NARROW,
	SOUTHEAST_NARROW,
	SOUTH_NARROW,
	SOUTHWEST_NARROW,
	EASTWEST_NARROW,
	NORTHSOUTH_NARROW
}
const E:int = LEVEL_FLOOR_TILE_ID
const W:int = LEVEL_WALL_TILE_ID
const N = null # anything; doesn't matter what the tile is
const NAV_CRITERIA:Dictionary = {
	# Defines the surrounding 8 tiles for each navmesh tile (1=wall, 0=empty)
	[N, W, N, W, E, N, E, E]: NAV_TILES.NORTHWEST,
	[N, W, N, E, E, E, E, E]: NAV_TILES.NORTH,
	[N, W, N, E, W, E, E, N]: NAV_TILES.NORTHEAST,
	[N, E, E, W, E, N, E, E]: NAV_TILES.WEST,
	[E, E, E, E, E, E, E, E]: NAV_TILES.EMPTY,
	[E, E, N, E, W, E, E, N]: NAV_TILES.EAST,
	[N, E, E, W, E, N, W, N]: NAV_TILES.SOUTHWEST,
	[E, E, E, E, E, N, W, N]: NAV_TILES.SOUTH,
	[E, E, N, E, W, N, W, N]: NAV_TILES.SOUTHEAST,
	[N, W, N, W, E, N, E, W]: NAV_TILES.NORTHWEST_NARROW,
	[N, W, N, E, E, W, E, W]: NAV_TILES.NORTH_NARROW,
	[N, W, N, E, W, W, E, N]: NAV_TILES.NORTHEAST_NARROW,
	[N, E, W, W, E, N, E, W]: NAV_TILES.WEST_NARROW,
	[W, E, W, E, E, W, E, W]: NAV_TILES.EMPTY_NARROW,
	[W, E, N, E, W, W, E, N]: NAV_TILES.EAST_NARROW,
	[N, E, W, W, E, N, W, N]: NAV_TILES.SOUTHWEST_NARROW,
	[W, E, W, E, E, N, W, N]: NAV_TILES.SOUTH_NARROW,
	[W, E, N, E, W, N, W, N]: NAV_TILES.SOUTHEAST_NARROW,
	[N, W, N, E, E, N, W, N]: NAV_TILES.EASTWEST_NARROW,
	[N, E, N, W, W, N, E, N]: NAV_TILES.NORTHSOUTH_NARROW
}
const NAV_TILEMAP:Dictionary = {
    # Corresponds to the navigation tile IDs in level-tileset.tres
	NAV_TILES.NORTHWEST: 			0,
	NAV_TILES.NORTH: 				1,
	NAV_TILES.NORTHEAST: 			2,
	NAV_TILES.WEST: 				3,
	NAV_TILES.EMPTY: 				4,
	NAV_TILES.EAST: 				5,
	NAV_TILES.SOUTHWEST: 			6,
	NAV_TILES.SOUTH: 				7,
	NAV_TILES.SOUTHEAST: 			8,
	NAV_TILES.NORTHWEST_NARROW: 	9,
	NAV_TILES.NORTH_NARROW: 		10,
	NAV_TILES.NORTHEAST_NARROW: 	11,
	NAV_TILES.WEST_NARROW: 			12,
	NAV_TILES.EMPTY_NARROW: 		13,
	NAV_TILES.EAST_NARROW: 			14,
	NAV_TILES.SOUTHWEST_NARROW: 	15,
	NAV_TILES.SOUTH_NARROW: 		16,
	NAV_TILES.SOUTHEAST_NARROW: 	17,
	NAV_TILES.EASTWEST_NARROW: 		18,
	NAV_TILES.NORTHSOUTH_NARROW: 	19
}

const PLAYER_MAX_HP:float = 100.0
var player_hp:float = PLAYER_MAX_HP


func is_floor_tile(id:int) -> bool:
    return (id == LEVEL_FLOOR_TILE_ID) or (id in NAV_TILEMAP.values())
