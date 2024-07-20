extends Node2D

@onready var LEVEL_MATRIX = $LEVEL_MATRIX

var LEVEL_JSON: Array = []
var TEMP_ARRAY: Array = []
var TEMP_NAME: String
@onready var LEVEL_NAME = get_node("DO_NOT_MOVE/LEVEL_NAME").get_child(0).name
@onready var GAME_MODE = get_node("DO_NOT_MOVE/GAME_MODE").get_child(0).name
func parse_level():
	var MAP_SIZE = LEVEL_MATRIX.get_used_rect().size
	var CURRENT_POSITION = Vector2(0,0)
	for i in range(0,MAP_SIZE.y):
		#print(i)
		for j in range(0,MAP_SIZE.x):
			#print(CURRENT_POSITION)
			var TEMP_TEMP = LEVEL_MATRIX.get_cell_atlas_coords(0,CURRENT_POSITION)
			TEMP_NAME = str(TEMP_TEMP.x,TEMP_TEMP.y)
			if TEMP_NAME.right(1) == "5":
				TEMP_NAME.right(1) == "9"
			TEMP_ARRAY.append(TEMP_NAME)
			CURRENT_POSITION.x += 1
		LEVEL_JSON.append(TEMP_ARRAY)
		TEMP_ARRAY = []
		CURRENT_POSITION.y += 1
		CURRENT_POSITION.x = 0
	#print(LEVEL_JSON)

var COUNTER = 0
func json_counter():
	COUNTER = 0
	var dir = DirAccess.open("res://levels")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir():
				if file_name.get_extension() == "json":
					COUNTER += 1
					#print("Found file: " + file_name)
			file_name = dir.get_next()

func save_json() -> void:
	if self.name == "level number here":
		print("ERROR: level number not set")
		return
	if LEVEL_NAME == "":
		print("ERROR: no level name set. exiting")
		#get_tree().quit()
		return
	elif LEVEL_NAME == "level name here":
		print("ERROR: no level name set. exiting")
		#get_tree().quit()
		return
	match GAME_MODE:
		"Classic":
			print("game_mode set to Classic")
		"Puzzle":
			print("game_mode set to Puzzle")
		_:
			print("ERROR: game mode needs to be either Classic or Puzzle.")
			#get_tree().quit()
			return
	if LEVEL_JSON == []:
		print("ERROR: no LEVEL_MATRIX tiles")
		#get_tree().quit()
		return
	var level_data := {"LEVEL_NAME":LEVEL_NAME,"GAME_MODE":GAME_MODE,"LEVEL_MATRIX":LEVEL_JSON}
	var level_string := JSON.stringify(level_data)
	json_counter()
	var file_name = str("res://levels/",self.name,".json")
	var file_access := FileAccess.open(file_name, FileAccess.WRITE)
	if not file_access:
		print("An error happened while saving data: ", FileAccess.get_open_error())
		return
	file_access.store_string(level_string)
	file_access.close()
	print("LEVEL_NAME: ", LEVEL_NAME)
	print("GAME_MODE: ", GAME_MODE)
	print("level saved to: /levels/",self.name,".json")
	

func _ready():
	parse_level()
	save_json()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
