class_name Level extends Node2D

@onready var generator:Node2D = $WFCGenerator
@onready var sample_tilemap:TileMapLayer = $WFCGenerator/Sample
@onready var target_tilemap:TileMapLayer = $WFCGenerator/Target
@onready var envelope_tilemap:TileMapLayer = $WFCGenerator/Envelope # patch target_tilemap
@onready var background_tilemap:TileMapLayer = $WFCGenerator/Background
@onready var camera:Camera2D = $WFCGenerator/Target/Camera2D
@onready var entities:Node2D = $Entities
@onready var level_label:Label = $GUI/LevelLabel
@onready var blood_bar:ProgressBar = $GUI/BloodBar
var width:int
var height:int
var current_level:int = 1
var exit_corner:Vector2


func _ready():
	MusicMan.level(true)


func _on_WFCGenerator_OnDone():
	# WARNING: generator's H & V are tilemap size + WFC window size
	width = generator.H
	height = generator.V
	camera.position = Vector2(width, height)*Vector2(target_tilemap.tile_set.tile_size)*0.5
	var corners = [Vector2(0, 0), Vector2(width-1, 0), Vector2(0, height-1), Vector2(width-1, height-1)]

	# encase the level in an invisible wall
	# trying to set_cell on target_tilemap does nothing? so I'll do this
	envelope_tilemap.position = -target_tilemap.tile_set.tile_size
	for y in range(height+2):
		for x in range(width+2):
			if (x==0 or y==0) or (x==width+1 or y==height+1):
				Global.set_cell_id(envelope_tilemap, Vector2i(x, y), Global.LEVEL_WALL_TILE_ID)
	# for the transparent wall tilemap sprite (purely aesthetic)
	background_tilemap.position = envelope_tilemap.position
	for y in range(height+2):
		for x in range(width+2):
			Global.set_cell_id(background_tilemap, Vector2i(x, y), Global.LEVEL_FLOOR_TILE_ID)

	var player = Global.PLAYER_SCENE.instantiate()
	assert(Global.player_hp)
	player.hp = Global.player_hp

	for y in range(height):
		for x in range(width):
			# Spawn entities from tilemap
			var tile:int = Global.get_cell_id(target_tilemap, Vector2i(x, y))
			if tile == Global.LEVEL_ENEMY_TILE_ID:
				Global.set_cell_id(envelope_tilemap, Vector2i(x+1, y+1), Global.LEVEL_FLOOR_TILE_ID)

				# Select an enemy type to spawn
				var enemy
				var prob := randf()
				if prob >= 0.8:
					enemy = Global.ENEMY_SHOOT_SCENE.instantiate()
				elif prob >= 0.6:
					enemy = Global.ENEMY_TANK_SCENE.instantiate()
				else:
					enemy = Global.ENEMY_SCENE.instantiate()

				enemy.tilemap = target_tilemap
				enemy.player = player
				enemy.global_position = _place_centered_tile(Vector2(x, y))
				entities.add_child(enemy)
			elif tile == Global.LEVEL_LAMP_TILE_ID:
				Global.set_cell_id(target_tilemap, Vector2i(x+1, y+1), Global.LEVEL_FLOOR_TILE_ID)
				var lamp = Global.LAMP_SCENE.instantiate()
				lamp.global_position = _place_centered_tile(Vector2(x, y))
				entities.add_child(lamp)

	# Setup the player
	player.tilemap = target_tilemap
	player.level = self
	player.new_hp.connect(_on_player_hp_changed)
	player.player_die.connect(_on_player_die)
	var player_corner:Vector2
	if current_level == 1:
		player_corner = corners[3] # same as the tutorial
	else:
		player_corner = exit_corner # same as the last exit
	player.global_position = _place_adjacent_random_empty(player_corner)
	entities.add_child(player)

	# Place the exit in a different corner
	var exit = Global.EXIT_SCENE.instantiate()
	exit.exit_reached.connect(_on_exit_reached)
	exit_corner = player_corner
	while exit_corner == player_corner:
		exit_corner = corners[randi() % corners.size()]
	exit.global_position = _place_adjacent_random_empty(exit_corner)
	entities.add_child(exit)

	# Fade in
	var tween = $GUI.create_tween()
	tween.tween_property($GUI/RedRect, "color:a", 0.0, 1.0)
	await tween.finished
	$GUI/RedRect.hide()
	get_tree().paused = false


func _place_centered_tile(pos:Vector2i) -> Vector2:
	# convert tilemap coords to global centered position
	return target_tilemap.map_to_local(pos)


func _place_adjacent_random_empty(startpos:Vector2) -> Vector2:
	var pos:Vector2 = startpos
	while Global.get_cell_id(target_tilemap, Vector2i(pos)) != Global.LEVEL_FLOOR_TILE_ID:
		var flip = randf()
		if flip <= 0.25 and pos.x < width-1:
			pos.x += 1
		elif flip <= 0.5 and pos.x > 0:
			pos.x -= 1
		elif flip <= 0.75 and pos.y < height-1:
			pos.y += 1
		elif flip <= 1.0 and pos.y > 0:
			pos.y -= 1
	return _place_centered_tile(pos)


func _on_exit_reached():
	get_tree().paused = true
	MusicMan.steps_sound()

	# Fade out
	$GUI/RedRect.show()
	var tween = $GUI.create_tween()
	tween.tween_property($GUI/RedRect, "color:a", 1.0, 1.0)
	await tween.finished

	# Reset scene
	for child in entities.get_children():
		if child is Player:
			Global.player_hp = child.hp # shitty hack
		child.queue_free()
	envelope_tilemap.clear()

	# Advance the level
	current_level += 1
	level_label.text = str(current_level)
	if current_level % 10 == 0:
		if current_level % 20 == 0: # remove walls, add enemies
			var walls = sample_tilemap.get_used_cells_by_id(Global.LEVEL_WALL_TILE_ID)
			if not walls.is_empty():
				var pick = walls[randi() % walls.size()]
				Global.set_cell_id(sample_tilemap, pick, Global.LEVEL_ENEMY_TILE_ID)
		if current_level == 40 or current_level == 70: # remove lamps
			var lamps = sample_tilemap.get_used_cells_by_id(Global.LEVEL_LAMP_TILE_ID)
			if not lamps.is_empty():
				var pick = lamps[lamps.size()-1]
				Global.set_cell_id(sample_tilemap, pick, Global.LEVEL_FLOOR_TILE_ID)
		generator._ready() # re-build Rules and generate
	elif current_level == 101:
		# WIN!
		pass
	else:
		generator._on_button_pressed() # generate new level


func _on_player_hp_changed(new_hp:float) -> void:
	blood_bar.value = new_hp


func _on_player_die():
	# Fade out
	get_tree().paused = true
	$GUI/RedRect.show()
	MusicMan.level(false, 1)
	MusicMan.player_dead = true
	var tween = $GUI.create_tween()
	tween.tween_property($GUI/RedRect, "color:a", 1.0, 1.0)
	await tween.finished
	$GUI/DeathLabel.show()
	await get_tree().create_timer(5.0).timeout
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
