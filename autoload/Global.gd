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
	EAST,
	SOUTHEAST,
	SOUTH,
	SOUTHWEST,
	WEST
}
const NAV_TILEMAP:Dictionary = {
    # Corresponds to the navigation tile IDs in level-tileset.tres
	NAV_TILES.NORTHWEST: 	4,
	NAV_TILES.NORTH: 		5,
	NAV_TILES.NORTHEAST: 	6,
	NAV_TILES.EAST: 		7,
	NAV_TILES.SOUTHEAST: 	8,
	NAV_TILES.SOUTH: 		9,
	NAV_TILES.SOUTHWEST: 	10,
	NAV_TILES.WEST: 		11
}
const PLAYER_MAX_HP:float = 100.0
var player_hp:float = PLAYER_MAX_HP


func is_floor_tile(id:int) -> bool:
    return (id == LEVEL_FLOOR_TILE_ID) or (id in NAV_TILEMAP.values())
