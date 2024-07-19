extends Node2D

@onready var LEVEL_MATRIX = $LEVEL_MATRIX

var coords: Array = []
var TEMP_ARRAY: Array = []
var TEMP_NAME: String
@onready var LEVEL_NAME = $level_name.text
@onready var GAME_MODE = $game_mode.text
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
		coords.append(TEMP_ARRAY)
		TEMP_ARRAY = []
		CURRENT_POSITION.y += 1
		CURRENT_POSITION.x = 0
	#print(coords)

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
	if LEVEL_NAME == "":
		print("ERROR: no level name set. exiting")
		#get_tree().quit()
		return
		#LEVEL_NAME = str("unnamed_level_",hmls.rng(0,9999))
	if coords == []:
		print("ERROR: no LEVEL_MATRIX_SET")
	var level_data := {"LEVEL_NAME":LEVEL_NAME,"GAME_MODE":GAME_MODE,"LEVEL_MATRIX":coords}
	var level_string := JSON.stringify(level_data)
	json_counter()
	var file_name = str("res://levels/",self.name,".json")
	var file_access := FileAccess.open(file_name, FileAccess.WRITE)
	if not file_access:
		print("An error happened while saving data: ", FileAccess.get_open_error())
		return
	file_access.store_string(level_string)
	file_access.close()

func _ready():
	parse_level()
	save_json()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
