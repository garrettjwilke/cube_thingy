extends Node2D

@onready var LEVEL_MATRIX = $LEVEL_MATRIX

var LEVEL_JSON: Array = []
var TEMP_ARRAY: Array = []
var TEMP_NAME: String
@onready var LEVEL_NAME = get_node("LEVEL_SETTINGS/LEVEL_NAME").get_child(0).name
@onready var GAME_MODE = get_node("LEVEL_SETTINGS/GAME_MODE").get_child(0).name
@onready var LEVEL_NUMBER = get_node("LEVEL_SETTINGS/LEVEL_NUMBER").get_child(0).name
func parse_level():
	var MAP_SIZE = LEVEL_MATRIX.get_used_rect().size
	if MAP_SIZE.x > 33:
		print("ERROR: LEVEL_MATRIX too large!")
		TEMP_ARRAY = []
		LEVEL_JSON = []
		return
	if MAP_SIZE.y > 33:
		print("ERROR: LEVEL_MATRIX too large!")
		TEMP_ARRAY = []
		LEVEL_JSON = []
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
			TEMP_ARRAY.append(TEMP_NAME)
			CURRENT_POSITION.x += 1
		LEVEL_JSON.append(TEMP_ARRAY)
		TEMP_ARRAY = []
		CURRENT_POSITION.y += 1
		CURRENT_POSITION.x = 0

func save_json() -> void:
	if LEVEL_NUMBER == "level number here":
		print("ERROR: level number not set")
		return
	if LEVEL_NUMBER == "":
		print("ERROR: level number not set")
		return
	if LEVEL_NAME == "":
		print("ERROR: no level name set. exiting")
		return
	elif LEVEL_NAME == "level name here":
		print("ERROR: no level name set. exiting")
		return
	match GAME_MODE:
		"Classic":
			print("game_mode set to Classic")
		"Puzzle":
			print("game_mode set to Puzzle")
		_:
			print("ERROR: game mode needs to be either Classic or Puzzle.")
			return
	if LEVEL_JSON == []:
		print("ERROR: no LEVEL_MATRIX tiles")
		return
	var level_data := {"LEVEL_NAME":LEVEL_NAME,"GAME_MODE":GAME_MODE,"LEVEL_MATRIX":LEVEL_JSON}
	var final_string := JSON.stringify(level_data)
	var file_name = str("res://levels/LEVEL_",LEVEL_NUMBER,".json")
	var file_access := FileAccess.open(file_name, FileAccess.WRITE)
	if not file_access:
		print("An error happened while saving data: ", FileAccess.get_open_error())
		return
	file_access.store_string(final_string)
	file_access.close()
	print("LEVEL_NAME: ", LEVEL_NAME)
	print("GAME_MODE: ", GAME_MODE)
	print("-----")
	print("level saved to:", file_name)
	

func _ready():
	parse_level()
	if LEVEL_JSON == []:
		print("ERROR: bad LEVEL_MATRIX")
		return
	save_json()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
