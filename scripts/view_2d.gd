extends Node2D
@onready var MENU_NODE = $menu
var LEVEL_INFO_NAME = "LEVEL_INFO"
var STATS_NODE_NAME = "STATS_CONTAINER"
var STATS_COLOR = "#9879a3"
var TOP_CONTAINER = str("top_bar/CenterContainer/", LEVEL_INFO_NAME)
var BOTTOM_CONTAINER = str("bottom_bar/CenterContainer/", STATS_NODE_NAME)
var LEFT_BOX = "left_box/CenterContainer"
@onready var TAB_GAME = $menu/center/marg/vbox/tabs/hbox/game_options/texture/center/Label
@onready var TAB_VIDEO = $menu/center/marg/vbox/tabs/hbox/video_options/texture/center/Label
@onready var TAB_AUDIO = $menu/center/marg/vbox/tabs/hbox/audio_options/texture/center/Label
@onready var TAB_CONTROLS = $menu/center/marg/vbox/tabs/hbox/controls_options/texture/center/Label
@onready var KEYBINDS_LABEL = $menu/center/marg/vbox/box/border/marg/bg/MarginContainer/controls/Label

# set the tile size for the 2d tiles
var TILE_SIZE_2D = 16

var FONT_THEME = hmls.get_default("FONT_THEME")
var FONT_1
var FONT_2

func set_font():
	match FONT_THEME:
		"1":
			FONT_1 = load("res://assets/fonts/manifold.ttf")
			FONT_2 = FONT_1
		"2":
			FONT_1 = load("res://assets/fonts/VictorMono-Bold.ttf")
			FONT_2 = load("res://assets/fonts/VictorMono-Medium.ttf")
		"3":
			FONT_1 = load("res://assets/fonts/lt-saeada-medium.otf")
			FONT_2 = FONT_1
		"4":
			FONT_1 = load("res://assets/fonts/Agave-Bold.ttf")
			FONT_2 = load("res://assets/fonts/Agave-Regular.ttf")
		"5":
			FONT_1 = load("res://assets/fonts/B612Mono-Bold.ttf")
			FONT_2 = load("res://assets/fonts/B612Mono-Regular.ttf")
		"6":
			FONT_1 = load("res://assets/fonts/overpass-mono-bold.otf")
			FONT_2 = load("res://assets/fonts/overpass-mono-regular.otf")
	TAB_GAME.add_theme_font_override("font", FONT_2)
	TAB_GAME.add_theme_font_size_override("font_size", FONT_SIZE_BIG)
	TAB_VIDEO.add_theme_font_override("font", FONT_2)
	TAB_VIDEO.add_theme_font_size_override("font_size", FONT_SIZE_BIG)
	TAB_AUDIO.add_theme_font_override("font", FONT_2)
	TAB_AUDIO.add_theme_font_size_override("font_size", FONT_SIZE_BIG)
	TAB_CONTROLS.add_theme_font_override("font", FONT_2)
	TAB_CONTROLS.add_theme_font_size_override("font_size", FONT_SIZE_BIG)
var FONT_SIZE_BIG = 28
var FONT_SIZE_SMALL = 16
var BOX_OFFSET = Vector2(16,16)

var KEYBINDS_TEXT = "------    Keybinds:    ------
Normal/Hard Toggle:  M
Restart Level:       R
Load Next Level:     N
Load Previous Level: B
Camera Toggle:       C
Rotate Cam Left:     Q
Rotate Cam Right:    E
Invert Cube:         I
Fullscreen Toggle:   F
  - (only works if this menu is showing)
	- for some reason it requires you to press it twice.

-----------------------

scroll test
check
1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
19
20
"

func spawn_info_node(NAME, COLOR, LOCATION, STRING):
	if LOCATION == "top":
		LOCATION = TOP_CONTAINER
	elif LOCATION == "bottom":
		LOCATION = BOTTOM_CONTAINER
	elif LOCATION == "left":
		LOCATION = LEFT_BOX
	var NEW_ITEM_SLOT = CenterContainer.new()
	NEW_ITEM_SLOT.name = str(NAME,"_BOX")
	var NEW_ITEM_BOX = ColorRect.new()
	NEW_ITEM_BOX.color = COLOR
	NEW_ITEM_BOX.name = NAME
	get_node(LOCATION).add_child(NEW_ITEM_SLOT)
	NEW_ITEM_SLOT.add_child(NEW_ITEM_BOX)
	var NEW_ITEM_LABEL = Label.new()
	NEW_ITEM_LABEL.name = str(NAME,"_LABEL")
	NEW_ITEM_LABEL.text = STRING
	NEW_ITEM_LABEL.add_theme_font_override("font", FONT_1)
	NEW_ITEM_LABEL.add_theme_font_size_override("font_size", FONT_SIZE_BIG)
	NEW_ITEM_SLOT.add_child(NEW_ITEM_LABEL)
	NEW_ITEM_BOX.custom_minimum_size = (NEW_ITEM_LABEL.size + BOX_OFFSET)

func spawn_menu_items():
	if get_node_or_null(TOP_CONTAINER):
		get_node("top_bar/CenterContainer").remove_child(get_node(TOP_CONTAINER))
	if get_node_or_null(BOTTOM_CONTAINER):
		get_node("bottom_bar/CenterContainer").remove_child(get_node(BOTTOM_CONTAINER))
	# add the top and bottom nodes that everything else will be attached to
	var new_node = HBoxContainer.new()
	new_node.name = LEVEL_INFO_NAME
	get_node("top_bar/CenterContainer").add_child(new_node)
	new_node = HBoxContainer.new()
	new_node.name = STATS_NODE_NAME
	get_node("bottom_bar/CenterContainer").add_child(new_node)
	# add level name container
	var NODE_NAME = "LEVEL_NAME"
	var LOCATION = "top"
	spawn_info_node(NODE_NAME,STATS_COLOR,LOCATION,hmls.LEVEL_NAME)
	# add top bar separator
	var NEW_ITEM_SLOT = CenterContainer.new()
	NEW_ITEM_SLOT.name = "SEPARATOR_BOX"
	get_node(TOP_CONTAINER).add_child(NEW_ITEM_SLOT)
	var separator_box = ColorRect.new()
	separator_box.name = "Separator"
	var separator_size = (1280.0/5.0)
	separator_box.custom_minimum_size = Vector2(separator_size,10)
	separator_box.color.a = 0.0
	NEW_ITEM_SLOT.add_child(separator_box)
	# add mode container
	NODE_NAME = "MODE"
	LOCATION = "top"
	spawn_info_node(NODE_NAME,STATS_COLOR,LOCATION,str("Mode: " ,hmls.GAME_MODE))

var TIMER_HUD = 0
func top_bar(MODE):
	if MODE == "reset":
		spawn_menu_items()
		return
	if MODE == "update":
		if hmls.PAUSE == false:
			pass
		return

func _on_signal_level_start():
	TIMER = 0
	top_bar("reset")

var SIDE_BAR_COLOR_1 = hmls.get_default("COLOR_BLACK")
var SIDE_BAR_COLOR_2 = "#98bb9c"
func side_bar(MODE):
	var TIMER_BOX_1 = $side_bar/CenterContainer/VBoxContainer/timer_node
	var TIMER_BOX_2 = $side_bar/CenterContainer/VBoxContainer/timer_node/cent/marg/crect
	var TIMER_LABEL = $side_bar/CenterContainer/VBoxContainer/timer_node/cent/marg/cent/timer_label
	var KEY_COUNT_BOX_1 = $side_bar/CenterContainer/VBoxContainer/key_count_node
	var KEY_COUNT_BOX_2 = $side_bar/CenterContainer/VBoxContainer/key_count_node/cent/marg/crect
	var KEY_COUNT_LABEL = $side_bar/CenterContainer/VBoxContainer/key_count_node/cent/marg/crect/vbox/cent/key_count_label
	var AMOUNT_LEFT_BOX_1 = $side_bar/CenterContainer/VBoxContainer/amount_left_node
	var AMOUNT_LEFT_BOX_2 = $side_bar/CenterContainer/VBoxContainer/amount_left_node/cent/marg/crect
	var AMOUNT_LEFT_LABEL = $side_bar/CenterContainer/VBoxContainer/amount_left_node/cent/marg/crect/cent/amount_left_label
	if MODE == "reset":
		if hmls.PAUSE == false:
			TIMER_BOX_1.color = SIDE_BAR_COLOR_1
			TIMER_BOX_2.color = SIDE_BAR_COLOR_2
			TIMER_LABEL.text = str("000")
			TIMER_LABEL.add_theme_font_override("font", FONT_2)
			TIMER_LABEL.add_theme_font_size_override("font_size", FONT_SIZE_BIG)
			TIMER_LABEL.set("theme_override_colors/font_color",hmls.get_default("COLOR_BLACK"))
			KEY_COUNT_BOX_1.color = SIDE_BAR_COLOR_1
			KEY_COUNT_BOX_2.color = SIDE_BAR_COLOR_2
			KEY_COUNT_LABEL.text = str("0/0")
			KEY_COUNT_LABEL.add_theme_font_override("font", FONT_2)
			KEY_COUNT_LABEL.add_theme_font_size_override("font_size", FONT_SIZE_BIG)
			KEY_COUNT_LABEL.set("theme_override_colors/font_color",hmls.get_default("COLOR_BLACK"))
			AMOUNT_LEFT_BOX_1.color = SIDE_BAR_COLOR_1
			AMOUNT_LEFT_BOX_2.color = SIDE_BAR_COLOR_2
			AMOUNT_LEFT_LABEL.text = str("0")
			AMOUNT_LEFT_LABEL.add_theme_font_override("font", FONT_2)
			AMOUNT_LEFT_LABEL.add_theme_font_size_override("font_size", 60)
			AMOUNT_LEFT_LABEL.set("theme_override_colors/font_color",hmls.get_default("COLOR_BLACK"))
			print("side bar reset")
	elif MODE == "update":
		TIMER_HUD = int(TIMER)
		var TEMP_TIMER = TIMER_HUD
		if TIMER_HUD < 1000:
			TEMP_TIMER = str("0", TIMER_HUD)
		if TIMER_HUD < 100:
			TEMP_TIMER = str("00", TIMER_HUD)
		if TIMER_HUD < 10:
			TEMP_TIMER = str("000", TIMER_HUD)
		TIMER_LABEL.text = TEMP_TIMER
		KEY_COUNT_LABEL.text = str(hmls.KEY_COUNT,"/",hmls.KEY_COUNT_TOTAL)
		match hmls.GAME_MODE:
			"Classic":
				if not AMOUNT_LEFT_BOX_1.is_visible():
					AMOUNT_LEFT_BOX_1.show()
				AMOUNT_LEFT_LABEL.text = str(hmls.AMOUNT_LEFT)
			_:
				if AMOUNT_LEFT_BOX_1.is_visible():
					AMOUNT_LEFT_BOX_1.hide()

func _ready():
	MENU_GAME.show()
	hmls.signal_level_start.connect(_on_signal_level_start)
	set_font()
	hmls.PAUSE = false
	MENU_NODE.hide()
	#KEYBINDS_LABEL.add_theme_font_override("font", FONT_2)
	#KEYBINDS_LABEL.add_theme_font_size_override("font_size", FONT_SIZE_SMALL)
	KEYBINDS_LABEL.text = KEYBINDS_TEXT
	top_bar("reset")
	side_bar("reset")

var LABEL_OFFSET = Vector2(10,10)

var TIMER = 0
func _process(delta):
	if MENU_NODE.is_visible_in_tree():
		hmls.PAUSE = true
	if hmls.PAUSE == false:
		TIMER += delta
	if Input.is_action_just_pressed("game_mode_key"):
		if hmls.GAME_DIFFICULTY == "normal":
			hmls.GAME_DIFFICULTY = "hard"
		else:
			hmls.GAME_DIFFICULTY = "normal"
	top_bar("update")
	side_bar("update")
	if Input.is_action_just_pressed("menu_button"):
		if MENU_NODE.is_visible_in_tree():
			MENU_NODE.hide()
			hmls.PAUSE = false
		else:
			MENU_NODE.show()

@onready var MENU_GAME = $menu/center/marg/vbox/box/border/marg/bg/MarginContainer/game_options
@onready var MENU_VIDEO = $menu/center/marg/vbox/box/border/marg/bg/MarginContainer/video_options
@onready var MENU_AUDIO = $menu/center/marg/vbox/box/border/marg/bg/MarginContainer/audio_options
@onready var MENU_CONTROLS = $menu/center/marg/vbox/box/border/marg/bg/MarginContainer/controls

func turn_off_menu():
	MENU_GAME.hide()
	MENU_VIDEO.hide()
	MENU_AUDIO.hide()
	MENU_CONTROLS.hide()

func _on_game_button_down():
	turn_off_menu()
	MENU_GAME.show()

func _on_video_button_down():
	turn_off_menu()
	MENU_VIDEO.show()

func _on_audio_button_down():
	turn_off_menu()
	MENU_AUDIO.show()

func _on_controls_button_down():
	turn_off_menu()
	MENU_CONTROLS.show()
