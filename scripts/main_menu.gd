extends Node2D

@onready var BG_NODE = $MarginContainer/bg

#var BG_RED = load("res://assets/textures/bg/01_red.tres")
#var BG_BLUE = load("res://assets/textures/bg/01_blue.tres")
#var BG_GREEN = load("res://assets/textures/bg/01_green.tres")
#var BG_YELLOW = load("res://assets/textures/bg/01_yellow.tres")
#var BG_ORANGE = load("res://assets/textures/bg/01_orange.tres")
#var BG_PURPLE = load("res://assets/textures/bg/01_purple.tres")
const BG_RED = "res://assets/textures/bg/01_red.tres"
const BG_BLUE = "res://assets/textures/bg/01_blue.tres"
const BG_GREEN = "res://assets/textures/bg/01_green.tres"
const BG_YELLOW = "res://assets/textures/bg/01_yellow.tres"
const BG_ORANGE = "res://assets/textures/bg/01_orange.tres"
const BG_PURPLE = "res://assets/textures/bg/01_purple.tres"

var MENU_NUMBER = 1

func set_bg():
	match MENU_NUMBER:
		1:
			BG_NODE.texture = load(BG_BLUE)
		2:
			BG_NODE.texture = load(BG_PURPLE)
		3:
			BG_NODE.texture = load(BG_GREEN)
		4:
			BG_NODE.texture = load(BG_YELLOW)
		5:
			BG_NODE.texture = load(BG_ORANGE)
		6:
			BG_NODE.texture = load(BG_RED)
		_:
			MENU_NUMBER = 1
			set_bg()

func _ready():
	set_bg()

var brightness_min = 0.6
var brightness_max = 1.0
var brightness = brightness_max
var LAST_MENU_NUMBER = 0
var speed = 0.002
var direction = "up"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("ACCEPT"):
		GLOBALS.GAME_MODE = "Classic"
		#MENU_NUMBER += 1
		# Move as long as the key/button is pressed.
		set_bg()
		print(MENU_NUMBER)
	if LAST_MENU_NUMBER != MENU_NUMBER:
		LAST_MENU_NUMBER = MENU_NUMBER
		set_bg()
	if brightness > brightness_max:
		brightness = brightness_max
		direction = "down"
	if brightness < brightness_min:
		brightness = brightness_min
		direction = "up"
	if direction == "up":
		brightness = brightness + speed
	elif direction == "down":
		brightness = brightness - speed
