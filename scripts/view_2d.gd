extends Node2D
@onready var MENU_NODE = $menu
var LEVEL_INFO_NAME = "LEVEL_INFO"
var STATS_NODE_NAME = "STATS_CONTAINER"
var STATS_COLOR = "#9879a3"
var TOP_CONTAINER = str("top_bar/CenterContainer/", LEVEL_INFO_NAME)
var BOTTOM_CONTAINER = str("bottom_bar/CenterContainer/", STATS_NODE_NAME)
var LEFT_BOX = "left_box/CenterContainer"
@onready var KEYBINDS_LABEL = $menu/CenterContainer/MarginContainer/VBoxContainer/keybinds/keybinds_label
@onready var KEYBINDS_BOX = $menu/CenterContainer/MarginContainer/VBoxContainer/keybinds/ColorRect
@onready var TABS_LABEL = $menu/CenterContainer/MarginContainer/VBoxContainer/tabs/Label


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
	- for some reason it requires you to press it twice."

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
	# add timer container
	#NODE_NAME = "TIMER"
	#LOCATION = "bottom"
	#spawn_info_node(NODE_NAME,STATS_COLOR,LOCATION,"Timer: 000")
	#get_node(str(BOTTOM_CONTAINER,"/TIMER_BOX")).position += Vector2(8,8)
	#TIMER_HUD = 0
	# add key count container
	#NODE_NAME = "KEY_COUNT"
	#LOCATION = "bottom"
	#spawn_info_node(NODE_NAME,STATS_COLOR,LOCATION,str("Keys: " ,hmls.KEY_COUNT))
	# add amount left node
	#NODE_NAME = "AMOUNT_LEFT"
	#LOCATION = "bottom"
	#spawn_info_node(NODE_NAME,STATS_COLOR,LOCATION,"Amount Left: 00")

var TIMER_HUD = 0
func top_bar(MODE):
	if MODE == "reset":
		spawn_menu_items()
		return
	if MODE == "update":
		if hmls.PAUSE == false:
			pass
			#TIMER_HUD = int(TIMER)
			#var TEMP_TIMER = TIMER_HUD
			#if TIMER_HUD < 100:
			#	TEMP_TIMER = str("0", TIMER_HUD)
			#if TIMER_HUD < 10:
			#	TEMP_TIMER = str("00", TIMER_HUD)
			#get_node(str(BOTTOM_CONTAINER,"/TIMER_BOX/TIMER_LABEL")).text = str("Timer: ", TEMP_TIMER)
			#get_node(str(BOTTOM_CONTAINER,"/KEY_COUNT_BOX/KEY_COUNT_LABEL")).text = str("Keys: " ,hmls.KEY_COUNT)
		#match hmls.GAME_MODE:
		#	"Classic":
		#		if not get_node(str(BOTTOM_CONTAINER,"/AMOUNT_LEFT_BOX")).is_visible():
		#			get_node(str(BOTTOM_CONTAINER,"/AMOUNT_LEFT_BOX")).show()
		#		get_node(str(BOTTOM_CONTAINER,"/AMOUNT_LEFT_BOX/AMOUNT_LEFT_LABEL")).text = str("Amount Left: ", hmls.AMOUNT_LEFT)
		#	_:
		#		if get_node(str(BOTTOM_CONTAINER,"/AMOUNT_LEFT_BOX")).is_visible():
		#			get_node(str(BOTTOM_CONTAINER,"/AMOUNT_LEFT_BOX")).hide()
		return

func _on_signal_level_start():
	TIMER = 0
	top_bar("reset")

func side_bar(MODE):
	var TIMER_NODE = $side_bar/VBoxContainer/timer_node
	var TIMER_LABEL = $side_bar/VBoxContainer/timer_node/cent/marg/cent/timer_label
	var KEY_COUNT_NODE = $side_bar/VBoxContainer/key_count_node
	var KEY_COUNT_LABEL = $side_bar/VBoxContainer/key_count_node/cent/marg/crect/vbox/cent/key_count_label
	var AMOUNT_LEFT_NODE = $side_bar/VBoxContainer/amount_left_node
	var AMOUNT_LEFT_LABEL = $side_bar/VBoxContainer/amount_left_node/cent/marg/crect/cent/amount_left_label
	if MODE == "reset":
		if hmls.PAUSE == false:
			TIMER_LABEL.text = str("000")
			TIMER_LABEL.add_theme_font_override("font", FONT_2)
			TIMER_LABEL.add_theme_font_size_override("font_size", FONT_SIZE_BIG)
			TIMER_LABEL.set("theme_override_colors/font_color",hmls.get_default("COLOR_BLACK"))
			KEY_COUNT_LABEL.text = str("0/0")
			KEY_COUNT_LABEL.add_theme_font_override("font", FONT_2)
			KEY_COUNT_LABEL.add_theme_font_size_override("font_size", FONT_SIZE_BIG)
			KEY_COUNT_LABEL.set("theme_override_colors/font_color",hmls.get_default("COLOR_BLACK"))
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
				if not AMOUNT_LEFT_NODE.is_visible():
					AMOUNT_LEFT_NODE.show()
				AMOUNT_LEFT_LABEL.text = str(hmls.AMOUNT_LEFT)
			_:
				if AMOUNT_LEFT_NODE.is_visible():
					AMOUNT_LEFT_NODE.hide()

func _ready():
	hmls.signal_level_start.connect(_on_signal_level_start)
	set_font()
	hmls.PAUSE = false
	MENU_NODE.hide()
	KEYBINDS_LABEL.add_theme_font_override("font", FONT_2)
	KEYBINDS_LABEL.add_theme_font_size_override("font_size", FONT_SIZE_BIG)
	KEYBINDS_LABEL.text = KEYBINDS_TEXT
	top_bar("reset")
	side_bar("reset")

var LABEL_OFFSET = Vector2(10,10)

var TIMER = 0
func _process(delta):
	if Input.is_action_just_pressed("game_mode_key"):
		if hmls.GAME_DIFFICULTY == "normal":
			hmls.GAME_DIFFICULTY = "hard"
		else:
			hmls.GAME_DIFFICULTY = "normal"
	if hmls.PAUSE == false:
		TIMER += delta
	top_bar("update")
	side_bar("update")
	if Input.is_action_just_pressed("menu_button"):
		if MENU_NODE.is_visible_in_tree():
			MENU_NODE.hide()
			hmls.PAUSE = false
		else:
			KEYBINDS_BOX.color = STATS_COLOR
			KEYBINDS_BOX.custom_minimum_size = KEYBINDS_LABEL.size + (BOX_OFFSET * 3)
			MENU_NODE.show()
			hmls.PAUSE = true
