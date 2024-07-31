extends Node2D

@onready var BG_NODE = $MarginContainer/bg

var BG_RED = load("res://assets/textures/bg/01_red.tres")
var BG_BLUE = load("res://assets/textures/bg/01_blue.tres")
var BG_GREEN = load("res://assets/textures/bg/01_green.tres")
var BG_YELLOW = load("res://assets/textures/bg/01_yellow.tres")
var BG_ORANGE = load("res://assets/textures/bg/01_orange.png")
var BG_PURPLE = load("res://assets/textures/bg/01_purple.tres")

var MENU_NUMBER = 0

func set_bg():
	match MENU_NUMBER:
		0:
			BG_NODE.texture = BG_BLUE
		1:
			BG_NODE.texture = BG_PURPLE
		2:
			BG_NODE.texture = BG_GREEN
		3:
			BG_NODE.texture = BG_YELLOW
		4:
			BG_NODE.texture = BG_ORANGE
		5:
			BG_NODE.texture = BG_RED

# Called when the node enters the scene tree for the first time.
func _ready():
	set_bg()
	pass # Replace with function body.

var brightness_min = 0.4
var brightness_max = 0.9
var brightness = brightness_min
var LAST_MENU_NUMBER = 0
var speed = 0.002
var direction = "up"
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
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
	BG_NODE.modulate = Color.from_hsv(1.0, 1.0, brightness)
