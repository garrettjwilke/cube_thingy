extends Node2D

var LEVEL = 1
var LEVEL_MATRIX = []
var GAME_MODE = hmls.get_default("GAME_MODE")
var LEVEL_STRING
var LEVEL_RESOLUTION = Vector2(0,0)
func load_level():
	# check if the level exists and load it as LEVEL_MATRIX
	LEVEL_STRING = str("res://levels/LEVEL_EDITOR_", LEVEL, ".json")
	if FileAccess.file_exists(LEVEL_STRING):
		var file = FileAccess.open(LEVEL_STRING, FileAccess.READ)
		var level_data = JSON.parse_string(file.get_as_text())
		# check if level json even has level data
		if level_data.has("LEVEL_MATRIX"):
			LEVEL_MATRIX = level_data.LEVEL_MATRIX
		else:
			LEVEL_MATRIX = hmls.get_default("LEVEL_MATRIX")
		if level_data.has("GAME_MODE"):
			GAME_MODE = level_data.GAME_MODE
		else:
			GAME_MODE = hmls.get_default("GAME_MODE")
	else:
		LEVEL_MATRIX = hmls.get_default("LEVEL_MATRIX")
		GAME_MODE = hmls.get_default("GAME_MODE")
		LEVEL = 1

func save_level():
	if not FileAccess.file_exists(LEVEL_STRING):
		print("no file. cant save")
		return

func parse_level():
	var tile = Vector2(0,0)
	var tile_base = "../editor/TILES"
	for row in LEVEL_MATRIX:
		for cell in row:
			if not get_node_or_null(tile_base):
				var NEW_NODE = Node2D.new()
				NEW_NODE.name = "TILES"
				get_node("../editor").add_child(NEW_NODE)
			tile.x += 1
			if tile.x > LEVEL_RESOLUTION.x:
				LEVEL_RESOLUTION.x += 1
		tile.x = 0
		tile.y += 1
		if tile.y > LEVEL_RESOLUTION.y:
			LEVEL_RESOLUTION.y += 1
	print(LEVEL_RESOLUTION)

func _ready():
	load_level()
	parse_level()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
