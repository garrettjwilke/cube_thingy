extends Node2D

@onready var LEVEL_MATRIX = $LEVEL_MATRIX

var LEVEL_JSON: Array = []
var TEMP_ARRAY: Array = []
var TEMP_NAME: String
@onready var LEVEL_NAME = get_node("LEVEL_SETTINGS/LEVEL_NAME").get_child(0).name
@onready var GAME_MODE = get_node("LEVEL_SETTINGS/GAME_MODE").get_child(0).name
@onready var LEVEL_NUMBER = get_node("LEVEL_SETTINGS/LEVEL_NUMBER").get_child(0).name
@onready var TILE_AMOUNT = get_node("LEVEL_SETTINGS/TILE_AMOUNT").get_child(0).name
var HAS_FINAL_ORB = false
var HAS_STARTING_POS = false

var STATUS_NODE = preload("res://scenes/2d/editor_status.tscn")
var COLOR_GOOD = "#2c603c"
var COLOR_BAD = "#8e2c2e"

func status_menu(status_color,message_1,message_2):
	if status_color == "good":
		$status/ColorRect/MarginContainer/status_color.color = COLOR_GOOD
	else:
		$status/ColorRect/MarginContainer/status_color.color = COLOR_BAD
	$status/ColorRect/MarginContainer/status_color/MarginContainer/CenterContainer/VBoxContainer/message_1.text = message_1
	$status/ColorRect/MarginContainer/status_color/MarginContainer/CenterContainer/VBoxContainer/message_2.text = message_2

var STATUS
func parse_level():
	var MAP_SIZE = LEVEL_MATRIX.get_used_rect().size
	if MAP_SIZE.x > 32:
		print("ERROR: LEVEL_MATRIX too large!")
		STATUS = "bad"
		status_menu(STATUS,"LEVEL_MATRIX too large!","there is max level size of 32x32 tiles.")
		return
	if MAP_SIZE.y > 32:
		print("ERROR: LEVEL_MATRIX too large!")
		STATUS = "bad"
		status_menu(STATUS,"LEVEL_MATRIX too large!","there is max level size of 32x32 tiles.")
		return
	var CURRENT_POSITION = Vector2(0,0)
	for i in range(0,MAP_SIZE.y):
		for j in range(0,MAP_SIZE.x):
			var TEMP_TEMP : Vector2 = LEVEL_MATRIX.get_cell_atlas_coords(0,CURRENT_POSITION)
			if TEMP_TEMP.x < 0:
				TEMP_TEMP = Vector2(0,0)
			if TEMP_TEMP.y < 0:
				TEMP_TEMP = Vector2(0,0)
			if TEMP_TEMP.x > 9:
				TEMP_TEMP = Vector2(0,0)
			if TEMP_TEMP.y > 9:
				TEMP_TEMP = Vector2(0,0)
			TEMP_NAME = str(TEMP_TEMP.x,TEMP_TEMP.y)
			if TEMP_NAME == "01":
				HAS_FINAL_ORB = true
			if TEMP_NAME.right(1) == "9":
				HAS_STARTING_POS = true
			TEMP_ARRAY.append(TEMP_NAME)
			CURRENT_POSITION.x += 1
		LEVEL_JSON.append(TEMP_ARRAY)
		TEMP_ARRAY = []
		CURRENT_POSITION.y += 1
		CURRENT_POSITION.x = 0

func save_json() -> void:
	if LEVEL_JSON == []:
		print("ERROR: no LEVEL_MATRIX tiles")
		status_menu("bad","No LEVEL_MATRIX set","set tiles using the LEVEL_MATRIX node")
		return
	match LEVEL_NUMBER:
		"","level number here":
			print("ERROR: level number not set")
			status_menu("bad","Level Number Not Set","rename the level number node with an integer")
			return
		_:
			if not LEVEL_NUMBER.is_valid_int():
				print("ERROR: level number not set")
				status_menu("bad","Level Number Not Set","rename the level number node with an integer")
				return
	match LEVEL_NAME:
		"","level name here":
			print("ERROR: no level name set. exiting")
			status_menu("bad","Level Name not set","rename the level name node")
			return
	match GAME_MODE:
		"Classic":
			print("game_mode set to Classic")
		"Puzzle":
			print("game_mode set to Puzzle")
		_:
			print("ERROR: game mode needs to be either Classic or Puzzle.")
			status_menu("bad","Game Mode not set","set the game mode to either Classic or Puzzle")
			return
	var COLOR_FLOOR = str("#",$LEVEL_SETTINGS/CUSTOM_COLORS/floor_color.color.to_html()).left(7)
	var COLOR_1 = str("#",$"LEVEL_SETTINGS/CUSTOM_COLORS/tile_colors/1".color.to_html()).left(7)
	var COLOR_2 = str("#",$"LEVEL_SETTINGS/CUSTOM_COLORS/tile_colors/2".color.to_html()).left(7)
	var COLOR_3 = str("#",$"LEVEL_SETTINGS/CUSTOM_COLORS/tile_colors/3".color.to_html()).left(7)
	var COLOR_4 = str("#",$"LEVEL_SETTINGS/CUSTOM_COLORS/tile_colors/4".color.to_html()).left(7)
	var COLOR_5 = str("#",$"LEVEL_SETTINGS/CUSTOM_COLORS/tile_colors/5".color.to_html()).left(7)
	var COLOR_6 = str("#",$"LEVEL_SETTINGS/CUSTOM_COLORS/tile_colors/6".color.to_html()).left(7)
	var COLOR_7 = str("#",$"LEVEL_SETTINGS/CUSTOM_COLORS/tile_colors/7".color.to_html()).left(7)
	var COLOR_8 = str("#",$"LEVEL_SETTINGS/CUSTOM_COLORS/tile_colors/8".color.to_html()).left(7)
	var level_data := {
		"LEVEL_NAME":LEVEL_NAME,
		"GAME_MODE":GAME_MODE,
		"LEVEL_MATRIX":LEVEL_JSON,
		"TILE_AMOUNT":TILE_AMOUNT,
		"COLOR_FLOOR":COLOR_FLOOR,
		"COLOR_1":COLOR_1,
		"COLOR_2":COLOR_2,
		"COLOR_3":COLOR_3,
		"COLOR_4":COLOR_4,
		"COLOR_5":COLOR_5,
		"COLOR_6":COLOR_6,
		"COLOR_7":COLOR_7,
		"COLOR_8":COLOR_8
		}
	var final_string := JSON.stringify(level_data)
	var file_name
	if GAME_MODE == "Classic":
		file_name = str("res://levels/Classic/Classic_LEVEL_",LEVEL_NUMBER,".json")
	elif GAME_MODE == "Puzzle":
		file_name = str("res://levels/Puzzle/Puzzle_LEVEL_",LEVEL_NUMBER,".json")
	var file_access := FileAccess.open(file_name, FileAccess.WRITE)
	if not file_access:
		print("An error happened while saving data: ", FileAccess.get_open_error())
		status_menu("bad","Could not save data","nothing i can do here. something fucked up")
		return
	file_access.store_string(final_string)
	file_access.close()
	print("LEVEL_NAME: ", LEVEL_NAME)
	print("GAME_MODE: ", GAME_MODE)
	print("-----")
	print("level saved to: ", file_name)
	status_menu("good","Level Saved!",str("level saved to:",file_name))

func _ready():
	$".".add_child(STATUS_NODE.instantiate())
	#get_node("status").show()
	parse_level()
	if STATUS == "bad":
		return
	if LEVEL_JSON == []:
		print("ERROR: bad LEVEL_MATRIX")
		STATUS = "bad"
		status_menu(STATUS,"No LEVEL_MATRIX set","set tiles using the LEVEL_MATRIX node")
		return
	if HAS_STARTING_POS == false:
		print("level requires a starting cube position")
		status_menu("bad","No Starting Position","set a starting cube position")

	if HAS_FINAL_ORB == false:
		print("level requires a final orb")
		status_menu("bad","No final orb set","level requires a final orb to be set")
		return
	save_json()
