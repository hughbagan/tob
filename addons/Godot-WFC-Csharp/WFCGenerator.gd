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
var used_rules:Dictionary = {} # {int, Array[Rule]} Holds tile occurrences in the sample for future use as rules
var tile_repetitions:Dictionary = {} # {int, int} Holds number of repetitions for each option. Used for calculating occurance probability.
var tilemap_array:Array = [] # Array[Array[int]] Holds tiles data for internal use only. Do not use directly! Use set_tile(), get_tile()
var tilemap_count:Array = [] # Array[Array[int]] Holds possible options counts
var max_n:int # total number of tiles that need to be set
var current_n:int = 0 # number of tiles currently set
var done:bool = false
var failed:bool = false
const TRY_FIX_TIMES:int = 10
var fail_count:int = 0
var fail_max:int = 1000
# var generation_task:Task
var task_last_state:bool = true # true means done
signal done


func _ready() -> void:
	randomize()
	done = false
	task_last_state = true
	current_n = 0
	failed = false
	fail_count = 0

	for i in H+match_radius*2:
		var row = []
		for j in H+match_radius*2:
			row.append(-1)
		tilemap_array.append(row)
