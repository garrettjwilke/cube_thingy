extends Node2D
@onready var COLOR_1 = GLOBALS.get_default("COLOR_GREEN")
@onready var COLOR_2 = GLOBALS.get_default("COLOR_YELLOW")
@onready var COLOR_3 = GLOBALS.get_default("COLOR_PURPLE")
@onready var COLOR_4 = GLOBALS.get_default("COLOR_RED")
@onready var COLOR_5 = GLOBALS.get_default("COLOR_BLUE")
@onready var COLOR_6 = GLOBALS.get_default("COLOR_ORANGE")
@onready var COLOR_1_SIDE = COLOR_1
@onready var COLOR_2_SIDE = COLOR_2
@onready var COLOR_3_SIDE = COLOR_3
@onready var COLOR_4_SIDE = COLOR_4
@onready var COLOR_5_SIDE = COLOR_5
@onready var COLOR_6_SIDE = COLOR_6
@onready var COLOR_HARD = "#000000"
@onready var COLOR_INVISIBLE = "#ffffff"
@onready var GAME_DIFFICULTY = GLOBALS.GAME_DIFFICULTY
@onready var INVERTED_MODE = GLOBALS.INVERTED_MODE

func get_all_children(in_node, array := []):
	array.push_back(in_node)
	for child in in_node.get_children():
		array = get_all_children(child, array)
	return array

func mode_thingy(DIFFICULTY,INVERTED):
	if INVERTED == "true":
		COLOR_1 = GLOBALS.get_default("COLOR_PURPLE")
		COLOR_2 = GLOBALS.get_default("COLOR_RED")
		COLOR_3 = GLOBALS.get_default("COLOR_GREEN")
		COLOR_4 = GLOBALS.get_default("COLOR_YELLOW")
		COLOR_5 = GLOBALS.get_default("COLOR_ORANGE")
		COLOR_6 = GLOBALS.get_default("COLOR_BLUE")
	else:
		COLOR_1 = GLOBALS.get_default("COLOR_GREEN")
		COLOR_2 = GLOBALS.get_default("COLOR_YELLOW")
		COLOR_3 = GLOBALS.get_default("COLOR_PURPLE")
		COLOR_4 = GLOBALS.get_default("COLOR_RED")
		COLOR_5 = GLOBALS.get_default("COLOR_BLUE")
		COLOR_6 = GLOBALS.get_default("COLOR_ORANGE")
	if DIFFICULTY == "normal":
		COLOR_1_SIDE = COLOR_1
		COLOR_2_SIDE = COLOR_2
		COLOR_3_SIDE = COLOR_3
		COLOR_4_SIDE = COLOR_4
		COLOR_5_SIDE = COLOR_5
		COLOR_6_SIDE = COLOR_6
	if DIFFICULTY == "hard":
		COLOR_1_SIDE = COLOR_HARD
		COLOR_2_SIDE = COLOR_HARD
		COLOR_3_SIDE = COLOR_HARD
		COLOR_4_SIDE = COLOR_HARD
		COLOR_5_SIDE = COLOR_HARD
		COLOR_6_SIDE = COLOR_HARD
	if DIFFICULTY == "invisible":
		COLOR_1 = COLOR_INVISIBLE
		COLOR_2 = COLOR_INVISIBLE
		COLOR_3 = COLOR_INVISIBLE
		COLOR_4 = COLOR_INVISIBLE
		COLOR_5 = COLOR_INVISIBLE
		COLOR_6 = COLOR_INVISIBLE
		COLOR_1_SIDE = COLOR_HARD
		COLOR_2_SIDE = COLOR_HARD
		COLOR_3_SIDE = COLOR_HARD
		COLOR_4_SIDE = COLOR_HARD
		COLOR_5_SIDE = COLOR_HARD
		COLOR_6_SIDE = COLOR_HARD

func set_colors():
	for i in get_all_children(get_tree().get_root()):
		match i.name:
			"1":
				i.color = COLOR_1
			"2":
				i.color = COLOR_2
			"3":
				i.color = COLOR_3
			"4":
				i.color = COLOR_4
			"5":
				i.color = COLOR_5
			"6":
				i.color = COLOR_6
		match i.name:
			"1_side":
				i.color = COLOR_1_SIDE
			"2_side":
				i.color = COLOR_2_SIDE
			"3_side":
				i.color = COLOR_3_SIDE
			"4_side":
				i.color = COLOR_4_SIDE
			"5_side":
				i.color = COLOR_5_SIDE
			"6_side":
				i.color = COLOR_6_SIDE
# Called when the node enters the scene tree for the first time.
func _ready():
	mode_thingy(GAME_DIFFICULTY,INVERTED_MODE)
	set_colors()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if GAME_DIFFICULTY != GLOBALS.GAME_DIFFICULTY:
		GAME_DIFFICULTY = GLOBALS.GAME_DIFFICULTY
		mode_thingy(GAME_DIFFICULTY,INVERTED_MODE)
		set_colors()
	if INVERTED_MODE != GLOBALS.INVERTED_MODE:
		INVERTED_MODE = GLOBALS.INVERTED_MODE
		mode_thingy(GAME_DIFFICULTY,INVERTED_MODE)
		set_colors()
