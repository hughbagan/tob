extends Node

const EXIT_SCENE:PackedScene = preload("res://scenes/entities/Exit.tscn")
const PLAYER_SCENE:PackedScene = preload("res://scenes/entities/Player.tscn")
const ENEMY_SCENE:PackedScene = preload("res://scenes/entities/Enemy.tscn")
const ENEMY_TANK_SCENE:PackedScene = preload("res://scenes/entities/TankEnemy.tscn")
const LAMP_SCENE:PackedScene = preload("res://scenes/entities/Lamp.tscn")
const LEVEL_FLOOR_TILE_ID:int = 0
const LEVEL_WALL_TILE_ID:int = 1
const LEVEL_ENEMY_TILE_ID:int = 2
const LEVEL_LAMP_TILE_ID:int = 3
const PLAYER_MAX_HP:float = 100.0
var player_hp:float
