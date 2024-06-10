class_name WFCGenerator extends Node2D

onready var target:TileMap = $Target # tilemap node to output to
onready var sample:TileMap = $Sample # tilemap node to create rules from
const EMPTY:int = -1 # no tile
export var H:int = 11 # map size horizontal
export var V:int = 11 # map size vertical
export var match_radius:int = 1 # the radius around a tile check for matching tiles with sample
export var correction_radius:int = 2 # the radius around a failed tile that will be cleared on fixing. A number bigger than match_radius is recommended.
export var choose_by_probability:bool = false
export var show_progress:bool = false # may impact performance
var used_rules:Dictionary # {int, Array[Rule]} Holds tile occurrences in the sample for future use as rules
var tile_repetitions:Dictionary # {int, int} Holds number of repetitions for each option. Used for calculating occurance probability.
var tilemap_array:Array # Array[Array[int]] Holds tiles data for internal use only. Do not use directly! Use set_tile(), get_tile()
var tilemap_count:Array # Array[Array[int]] Holds possible options counts
var max_n:int # total number of tiles that need to be set
var current_n:int = 0 # number of tiles currently set
var failed:bool = false
const TRY_FIX_TIMES:int = 10
var fail_count:int = 0
var fail_max:int = 400
var generation_thread:Thread
signal done


func _ready() -> void:
	randomize()
	generation_thread = Thread.new()
	used_rules = {}
	tile_repetitions = {}
	tilemap_array = []
	tilemap_count = []
	current_n = 0
	failed = false
	fail_count = 0

	for i in H+match_radius*2:
		var row = []
		for j in H+match_radius*2:
			row.append(-1)
		tilemap_array.append(row)

	for i in H+match_radius*2:
		var column = []
		for j in V:
			column.append(-1)
		tilemap_count.append(column)

	sample.hide()
	max_n = H*V
	init() # needs to be called to initialize used_tiles (to create rules)
	clear_map()
	update_count_all()
	generate_map()


func _process(delta:float) -> void:
	if show_progress: # expensive!
		apply_tilemap()
	if generation_thread.is_active():
		if not generation_thread.is_alive():
			# when the generation is done, apply the output to the tilemap and finish up.
			var result = generation_thread.wait_to_finish()
			if result != OK:
				printerr("GEN ERROR: ", result)
			apply_tilemap()
			emit_signal("done")


# Starts generating the map on a new thread
func generate_map(clear_target:bool = true) -> void:
	generation_thread.start(self, "_generate_map", clear_target)
	print("started ", generation_thread.get_id())


# Generates map
func _generate_map(clear_target:bool = true):
	if clear_target:
		clear_map()
	update_count_all()

	while true:
		if current_n >= max_n:
			break
		var next_tile:Vector2 = get_next_tile() # find the next tile to set
		#print(current_n, "/", max_n, " ", next_tile)
		if get_tile(next_tile) != EMPTY:
			failed = true

		var options:Array = get_options(next_tile) # what can we put in this tile?
		if choose_by_probability:
			set_tile(next_tile, choose_option(options)) # set tile based on its occurance
		else:
			set_tile(next_tile, options[randi() % options.size()]) # set tile to a random possible option
		update_count_radius(next_tile, match_radius)

		current_n += 1

	if failed:
		# for i in TRY_FIX_TIMES:
		fail_count += 1
		if fail_count > fail_max:
			print("generator stuck; start over")
			# TODO: refactor to a more appropriate function name
			_on_button_pressed() # regenerates without Init() (re-building rules)
		fix_fail()
	return OK


# Apply the tile array to the target tilemap
func apply_tilemap() -> void:
	for i in H:
		for j in V:
			target.set_cell(i, j, get_tile(Vector2(i, j)))


# Create the rules from the sample tilemap
func init() -> void:
	used_rules.clear()
	tile_repetitions.clear()
	var used_cells:Array = sample.get_used_cells() # Array[Vector2]
	for cell in used_cells:
		var tile_id:int = sample.get_cell(cell.x, cell.y)
		if not used_rules.has(tile_id):
			used_rules[tile_id] = [] # Array[Rule]
		var rule:Rule = Rule.new(match_radius, cell, sample)
		var repeated:bool = false
		for r in used_rules[tile_id]:
			if r.compare_with(rule):
				repeated = true
				break
		if not repeated:
			used_rules[tile_id].append(rule)
		# add to tile_repetitions
		if not tile_repetitions.has(tile_id):
			tile_repetitions[tile_id] = 0
		tile_repetitions[tile_id] += 1


# Called on fail to redraw failed parts
func fix_fail() -> void:
	var cleared_count:int = 0
	for tile in get_empty_tiles():
		cleared_count += clear_radius(tile, match_radius*2)
		cleared_count += 1 # because we need to count the middle tile (which is already empty) as well
	current_n = max_n - cleared_count
	failed = false
	print("failed; fix fail")
	_generate_map(false)


# Returns the number of possible options for given tile coords
func get_options_count(coord:Vector2) -> int:
	var count:int = 0
	for tile_id in used_rules.keys():
		var f:bool = true
		var b:bool = false
		# "intelligent" vs "exact" generation type would go here...
		for i in range(-match_radius, match_radius+1, 1):
			if b: break
			for j in range(-match_radius, match_radius+1, 1):
				if b: break
				var any_match:bool = false
				for rule in used_rules[tile_id]:
					if do_tiles_match(get_tile(coord+Vector2(i, j)), rule.rule_array[match_radius+i][match_radius+j]):
						any_match = true
				if not any_match:
					f = false
					b = true
		if f: count += 1
	return count


# Returns all possible options for the given tile coordinates
func get_options(coord:Vector2) -> Array: # Array[int]
	var options:Array = []
	for tile_id in used_rules.keys():
		var f:bool = true
		var b:bool = false
		for i in range(-match_radius, match_radius+1, 1):
			if b: break
			for j in range(-match_radius, match_radius+1, 1):
				if b: break
				var any_match:bool = false
				for rule in used_rules[tile_id]:
					if do_tiles_match(get_tile(coord+Vector2(i, j)), rule.rule_array[match_radius+i][match_radius+j]):
						any_match = true
				if not any_match:
					f = false
					b = true
		if f: options.append(tile_id)
	return options


# Chooses a tile from the given options based on its occurance proability
func choose_option(options:Array) -> int: # Array[int]
	if options.empty():
		return EMPTY
	var sum:int = 0
	for option in options:
		sum += tile_repetitions[option]
	var temp:int = 0
	var rand:int = randi() % sum
	for option in options:
		temp += tile_repetitions[option]
		if temp >= rand:
			return option
	return EMPTY


# Returns true if the two given tiles match (or if one is not set)
func do_tiles_match(tile1:int, tile2:int) -> bool:
	# TODO: duplicate of Rule.do_tiles_match !! Where does it belong?
	return tile1 == EMPTY or tile2 == tile1


# Returns the tile with the least possible options
func get_next_tile() -> Vector2:
	var best_tile:Vector2 = Vector2()
	var least_options:int = 9223372036854775807 # max value; infinity or un-initialized
	for i in H:
		for j in V:
			if tilemap_count[i][j] < least_options and tilemap_count[i][j] > 0:
				least_options = tilemap_count[i][j]
				best_tile.x = i
				best_tile.y = j
	return best_tile


# Updates all options counts
func update_count_all() -> void:
	for i in H:
		for j in V:
			var coord:Vector2 = Vector2(i, j)
			if get_tile(coord) != EMPTY:
				tilemap_count[i][j] = 0
			else:
				tilemap_count[i][j] = get_options_count(coord)


func update_count_radius(coord:Vector2, radius:int) -> void:
	var threads:Array = [] # Array[Thread]
	var counts:Array = [] # Array[Array[int]]
	for i in range(coord.x-radius, coord.x+radius+1, 1):
		for j in range(coord.y-radius, coord.y+radius+1, 1):
			if i<0 or j<0 or i>=H or j>= V:
				continue
			var tempcoord:Vector2 = Vector2(i, j)
			if get_tile(tempcoord) != EMPTY:
				tilemap_count[i][j] = 0
			else:
				var thread = Thread.new()
				thread.start(self, "get_options_count", tempcoord)
				threads.append(thread)
				var intarr = [-1,-1]
				intarr[0] = i
				intarr[1] = j
				counts.append(intarr)
	for i in threads.size():
		tilemap_count[counts[i][0]][counts[i][1]] = threads[i].wait_to_finish()


# Set every tilemap_array cell to (-1, -1)
func clear_map() -> void:
	for i in H+match_radius*2:
		for j in V+match_radius*2:
			tilemap_array[i][j] = EMPTY


# Set every tilemap_array cell in the specified radius and position to (-1, -1). Returns number of tiles that were not (-1, -1) before clearing.
func clear_radius(coord:Vector2, radius:int) -> int:
	var cleared_count:int = 0
	for i in range(coord.x-radius, coord.x+radius+1, 1):
		for j in range(coord.y-radius, coord.y+radius+1, 1):
			if i<0 or j<0 or i>=H or j>=V:
				continue
			var tempcoord:Vector2 = Vector2(i, j)
			if get_tile(tempcoord) != EMPTY:
				cleared_count += 1
			set_tile(tempcoord, EMPTY)
	return cleared_count


# Returns a list of all tiles that are empty. (-1, -1)
func get_empty_tiles() -> Array: # Array[Vector2]
	var tiles:Array = []
	for i in H:
		for j in V:
			if get_tile(Vector2(i, j)) == EMPTY:
				tiles.append(Vector2(i, j))
	return tiles


# Get tile from tilemap_array using coordinates
func get_tile(coord:Vector2) -> int:
	return tilemap_array[coord.x+match_radius][coord.y+match_radius]


# Set tile on tilemap_array using coordinates
func set_tile(coord:Vector2, value:int) -> void:
	tilemap_array[coord.x+match_radius][coord.y+match_radius] = value


func _on_button_pressed() -> void:
	# TODO: to kill a thread I would need to track a stop request inside the thread
	# and then wait_to_finish()
	tilemap_array = []
	tilemap_count = []

	current_n = 0
	failed = false
	fail_count = 0

	tilemap_array = []
	for i in H+match_radius*2:
		var row = []
		for j in H+match_radius*2:
			row.append(-1)
		tilemap_array.append(row)

	for i in H+match_radius*2:
		var column = []
		for j in V:
			column.append(-1)
		tilemap_count.append(column)

	sample.hide()
	max_n = H*V
	clear_map()
	update_count_all()
	generate_map()
