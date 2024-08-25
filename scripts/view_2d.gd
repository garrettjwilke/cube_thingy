extends Node2D
@onready var MENU_NODE = $menu
var LEVEL_INFO_NAME = "LEVEL_INFO"
var STATS_NODE_NAME = "STATS_CONTAINER"
var STATS_COLOR = "#9879a3"
var TOP_CONTAINER = str("top_bar/CenterContainer/", LEVEL_INFO_NAME)
var TAB_INACTIVE = preload("res://assets/textures/menu_tab_inactive.tres")
var TAB_ACTIVE = preload("res://assets/textures/menu_tab_active.tres")
@onready var TAB_GAME_CONTENT = $menu/center/marg/vbox/box/border/marg/bg/marg/game_options
@onready var TAB_VIDEO_CONTENT = $menu/center/marg/vbox/box/border/marg/bg/marg/video_options
@onready var TAB_CONTROLS_CONTENT = $menu/center/marg/vbox/box/border/marg/bg/marg/controls
@onready var TAB_GAME_TEXTURE = $menu/center/marg/vbox/tabs/hbox/game_options/texture
@onready var TAB_VIDEO_TEXTURE = $menu/center/marg/vbox/tabs/hbox/video_options/texture
@onready var TAB_CONTROLS_TEXTURE = $menu/center/marg/vbox/tabs/hbox/controls_options/texture
@onready var KEYBINDS_LABEL = $menu/center/marg/vbox/box/border/marg/bg/marg/controls/Label

# set the tile size for the 2d tiles
var TILE_SIZE_2D = 16

var FONT_THEME = GLOBALS.get_default("FONT_THEME")
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
Move Cube:           Up/Down/Left/Right or A/S/D/W
Rotate Cam Left:     Q
Rotate Cam Right:    E
Camera Zoom:         C
Restart Level:       R
Load Next Level:     N
Load Previous Level: B
"

func spawn_info_node(NAME, COLOR, STRING):
	var NEW_ITEM_SLOT = CenterContainer.new()
	NEW_ITEM_SLOT.name = str(NAME,"_BOX")
	var NEW_ITEM_BOX = ColorRect.new()
	NEW_ITEM_BOX.color = COLOR
	NEW_ITEM_BOX.name = NAME
	get_node(TOP_CONTAINER).add_child(NEW_ITEM_SLOT)
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
	# add the top and bottom nodes that everything else will be attached to
	var new_node = HBoxContainer.new()
	new_node.name = LEVEL_INFO_NAME
	get_node("top_bar/CenterContainer").add_child(new_node)
	new_node = HBoxContainer.new()
	# add level name container
	var NODE_NAME = "LEVEL_NAME"
	spawn_info_node(NODE_NAME,STATS_COLOR,GLOBALS.LEVEL_NAME)
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
	spawn_info_node(NODE_NAME,STATS_COLOR,str("Mode: " ,GLOBALS.GAME_MODE))

var TIMER_HUD = 0
func top_bar(MODE):
	if MODE == "reset":
		spawn_menu_items()
		return
	if MODE == "update":
		if GLOBALS.PAUSE == false:
			pass
		return

func _on_signal_level_start():
	TIMER = 0
	top_bar("reset")

func _on_signal_level_end():
	get_node("start_end_screen").show()

var SIDE_BAR_COLOR_1 = GLOBALS.CURRENT_BLACK
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
		if GLOBALS.PAUSE == false:
			TIMER_BOX_1.color = SIDE_BAR_COLOR_1
			TIMER_BOX_2.color = SIDE_BAR_COLOR_2
			TIMER_LABEL.text = str("000")
			TIMER_LABEL.add_theme_font_override("font", FONT_2)
			TIMER_LABEL.add_theme_font_size_override("font_size", FONT_SIZE_BIG)
			TIMER_LABEL.set("theme_override_colors/font_color",GLOBALS.CURRENT_BLACK)
			KEY_COUNT_BOX_1.color = SIDE_BAR_COLOR_1
			KEY_COUNT_BOX_2.color = SIDE_BAR_COLOR_2
			KEY_COUNT_LABEL.text = str("0/0")
			KEY_COUNT_LABEL.add_theme_font_override("font", FONT_2)
			KEY_COUNT_LABEL.add_theme_font_size_override("font_size", FONT_SIZE_BIG)
			KEY_COUNT_LABEL.set("theme_override_colors/font_color",GLOBALS.CURRENT_BLACK)
			AMOUNT_LEFT_BOX_1.color = SIDE_BAR_COLOR_1
			AMOUNT_LEFT_BOX_2.color = SIDE_BAR_COLOR_2
			AMOUNT_LEFT_LABEL.text = str("0")
			AMOUNT_LEFT_LABEL.add_theme_font_override("font", FONT_2)
			AMOUNT_LEFT_LABEL.add_theme_font_size_override("font_size", 60)
			AMOUNT_LEFT_LABEL.set("theme_override_colors/font_color",GLOBALS.CURRENT_BLACK)
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
		KEY_COUNT_LABEL.text = str(GLOBALS.KEY_COUNT,"/",GLOBALS.KEY_COUNT_TOTAL)
		match GLOBALS.GAME_MODE:
			"Classic":
				if not AMOUNT_LEFT_BOX_1.is_visible():
					AMOUNT_LEFT_BOX_1.show()
				AMOUNT_LEFT_LABEL.text = str(GLOBALS.AMOUNT_LEFT)
			_:
				if AMOUNT_LEFT_BOX_1.is_visible():
					AMOUNT_LEFT_BOX_1.hide()

func _ready():
	get_node("start_end_screen").hide()
	turn_off_menu()
	TAB_GAME_TEXTURE.texture = TAB_ACTIVE
	TAB_GAME_CONTENT.show()
	GLOBALS.signal_level_start.connect(_on_signal_level_start)
	GLOBALS.signal_level_end.connect(_on_signal_level_end)
	set_font()
	#GLOBALS.PAUSE = false
	MENU_NODE.hide()
	KEYBINDS_LABEL.text = KEYBINDS_TEXT
	top_bar("reset")
	side_bar("reset")

var TIMER = 0
func _process(delta):
	if MENU_NODE.is_visible_in_tree():
		if GLOBALS.PAUSE == false:
			GLOBALS.PAUSE = true
	if GLOBALS.PAUSE == false:
		TIMER += delta
	top_bar("update")
	side_bar("update")
	if Input.is_action_just_pressed("menu_button"):
		if MENU_NODE.is_visible_in_tree():
			MENU_NODE.hide()
			GLOBALS.PAUSE = false
		else:
			MENU_NODE.show()

func set_state():
	print("put all state stuff here - view_2d.gd")

func turn_off_menu():
	TAB_GAME_CONTENT.hide()
	TAB_GAME_TEXTURE.texture = TAB_INACTIVE
	TAB_VIDEO_CONTENT.hide()
	TAB_VIDEO_TEXTURE.texture = TAB_INACTIVE
	TAB_CONTROLS_CONTENT.hide()
	TAB_CONTROLS_TEXTURE.texture = TAB_INACTIVE

func _on_game_button_down():
	turn_off_menu()
	TAB_GAME_CONTENT.show()
	TAB_GAME_TEXTURE.texture = TAB_ACTIVE
func _on_video_button_down():
	turn_off_menu()
	TAB_VIDEO_CONTENT.show()
	TAB_VIDEO_TEXTURE.texture = TAB_ACTIVE
func _on_controls_button_down():
	turn_off_menu()
	TAB_CONTROLS_CONTENT.show()
	TAB_CONTROLS_TEXTURE.texture = TAB_ACTIVE

func _on_fullscreen_disabled_button_down():
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	print(DisplayServer.window_get_mode(0))

func _on_fullscreen_enabled_button_down():
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	print(DisplayServer.window_get_mode(0))

func _on_disable_shaders_button_down():
	GLOBALS.ENABLE_SHADERS = false

func _on_enable_shaders_button_down():
	GLOBALS.ENABLE_SHADERS = true

func _on_close_menu_button_down():
	if MENU_NODE.is_visible_in_tree():
		MENU_NODE.hide()
		GLOBALS.PAUSE = false
	else:
		MENU_NODE.show()

func _on_difficulty_normal_button_down():
	GLOBALS.GAME_DIFFICULTY = "normal"
func _on_difficulty_hard_button_down():
	GLOBALS.GAME_DIFFICULTY = "hard"
func _on_difficulty_invisible_button_down():
	GLOBALS.GAME_DIFFICULTY = "invisible"

func _on_inverted_cube_disable_button_down():
	GLOBALS.INVERTED_MODE = "false"
func _on_inverted_cube_enable_button_down():
	GLOBALS.INVERTED_MODE = "true"

func _on_rng_seed_edit_text_changed(new_text):
	GLOBALS.RNG_SEED = new_text

func _on_music_disable_button_down():
	GLOBALS.MUTE_MUSIC = true
func _on_music_enable_button_down():
	GLOBALS.MUTE_MUSIC = false
func _on_sound_effects_disable_button_down():
	GLOBALS.MUTE_SOUNDS = true
func _on_sound_effects_enable_button_down():
	GLOBALS.MUTE_SOUNDS = false

func _on_main_menu_button_button_down():
	print("go to main menu when it's actually made")
func _on_restart_level_button_button_down():
	GLOBALS.update_tiles("reset")
	GLOBALS.update_tiles("3d")
	GLOBALS.RESET_LEVEL = true
	get_node("start_end_screen").hide()
func _on_next_level_button_button_down():
	GLOBALS.update_level(1)
	GLOBALS.update_tiles("reset")
	GLOBALS.update_tiles("3d")
	GLOBALS.RESET_LEVEL = true
	get_node("start_end_screen").hide()

func _on_inverted_cam_disable_button_down():
	GLOBALS.INVERT_CAM = false
func _on_inverted_cam_enable_button_down():
	GLOBALS.INVERT_CAM = true
