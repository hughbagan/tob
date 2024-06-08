class_name Rule extends Node

const EMPTY:int = -1 # no tile
var rule_array:Array = [] # 2D array


static func construct(match_radius:int, position:Vector2, sample:TileMap) -> Rule:
	var new_rule = Rule.new()
	var match_rad_vector:Vector2 = Vector2(match_radius, match_radius)
	new_rule.create_rule_array()
	for i in new_rule.rule_array.size():
		for j in new_rule.rule_array.size():
			var coord:Vector2 = position-match_rad_vector+Vector2(i, j)
			var tile_id:int = sample.get_cell(coord.x, coord.y)
			new_rule.rule_array[i][j] = tile_id
	return new_rule


func create_rule_array(match_radius:int) -> void:
	for i in 1+match_radius*2:
		var row = []
		for j in 1+match_radius*2:
			row.append(-1)
		rule_array.append(row)


func get_match_radius() -> int:
	return (rule_array.size()-1)/2


func compare_with(rule:Rule, ignore_1_in_rule2:bool=false) -> bool:
	return compare_rules(self, rule, ignore_1_in_rule2)


static func compare_rules(rule1:Rule, rule2:Rule, ignore_1_in_rule2:bool=false) -> bool:
	var rule_array_size:int = rule1.rule_array.size()
	if rule_array_size != rule2.rule_array.size():
		return false
	if not ignore_1_in_rule2:
		for i in rule_array_size:
			for j in rule_array_size:
				if rule1.rule_array[i][j] != rule2.rule_array[i][j]:
					return false
		return true
	else:
		for i in rule_array_size:
			for j in rule_array_size:
				if not do_tiles_match(rule1.rule_array[i][j], rule2.rule_array[i][j]):
					return false
		return true


static func do_tiles_match(tile1:int, tile2:int) -> bool:
	return tile1 == EMPTY || tile2 == tile1


func print_rule() -> void:
	print("{")
	for i in rule_array.size():
		var s = ""
		for j in rule_array.size():
			s += str(rule_array[j][i])+","
		print(s)
	print("}")
