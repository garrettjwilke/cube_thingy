extends Node

var wtf = ""

var IS_READY = false
var DEBUG = false
# setting DEBUG_SEVERITY can help isolate debug messages
#   setting to 0 will show all debug messages
var DEBUG_SEVERITY = 0

# this is set after the level matrix has been loaded
var CURRENT_LEVEL = []
# this will get set with the level data later
var LEVEL_MATRIX = []
# other parts of the game need to know the dimensions of the level. this is added up as we spawn tiles
var LEVEL_RESOLUTION = Vector2(0,0)
var LEVEL_NAME = get_default("LEVEL_NAME")
var GAME_MODE = get_default("GAME_MODE")
var ENABLE_JANK = get_default("ENABLE_JANK")
var TILE_SIZE_2D = 16
var START_POSITION = Vector2(0,0)
var GAME_DIFFICULTY = get_default("GAME_DIFFICULTY")
var CLOSE_UP_CAM = true
var ROTATION_COUNT = 1
var ENABLE_SHADERS = false
var OS_CHECK = "null"
var PAUSE = true
var INVERTED_MODE = get_default("INVERTED_MODE")
var INVERT_CAM = false
var RESET_LEVEL = false

var MUTE_MUSIC = false
var MUTE_SOUNDS = false

var AMOUNT_LEFT_LEVEL = "0"
var AMOUNT_LEFT = 0
var KEY_COUNT = 0
var KEY_BLANK = 0
var KEY_RED = 0
var KEY_GREEN = 0
var KEY_BLUE = 0
var KEY_YELLOW = 0
var KEY_PURPLE = 0
var KEY_ORANGE = 0
func reset_keys():
	KEY_COUNT = 0
	KEY_BLANK = 0
	KEY_RED = 0
	KEY_GREEN = 0
	KEY_BLUE = 0
	KEY_YELLOW = 0
	KEY_PURPLE = 0
	KEY_ORANGE = 0
var KEY_COUNT_TOTAL = 0

var BOX_MESH = preload("res://scenes/3d/block_3d.tscn")
var NEW_TILE = MeshInstance3D.new()

signal signal_detonator(COLOR)
signal signal_level_start()
signal signal_level_end()

# round number up/down
func round_to_dec(num):
	return round(num * pow(10.0, 0)) / pow(10.0, 0)

# round vector3
func round_vect3(data):
	data.x = round(data.x * pow(10.0,0))
	data.y = round(data.y * pow(10.0,0))
	data.z = round(data.z * pow(10.0,0))
	return data

# you can control the outcome of the RNG with a seed
var RNG_SEED = get_default("RNG_SEED")
var RNG_COUNTER = 0
func update_rng_seed(new_seed):
	RNG_SEED = new_seed
	RNG_COUNTER = 0

func rng(MIN, MAX):
	RNG_COUNTER += 1
	var number = RandomNumberGenerator.new()
	# combine the RNG number with the seed and you get a new_seed unique from the rest
	# if we skip this, we run into a chance where the RNG produces the same result and the game breaks
	var new_seed = str(RNG_SEED, str(RNG_COUNTER)).hash()
	number.randomize()
	number.set_seed(new_seed)
	number = number.randi_range(MIN, MAX)
	return number

func rng_float(MIN, MAX):
	RNG_COUNTER += 1
	var number = RandomNumberGenerator.new()
	# combine the RNG number with the seed and you get a new_seed unique from the rest
	# if we skip this, we run into a chance where the RNG produces the same result and the game breaks
	var new_seed = str(RNG_SEED, str(RNG_COUNTER)).hash()
	number.randomize()
	number.set_seed(new_seed)
	number = number.randf_range(MIN, MAX)
	return number

# when calling debug message, you need to set a severity
# if the DEBUG_SEVERITY is set to 0, it will display all debug messages
func debug_message(INFO, MESSAGE, SEVERITY):
	if DEBUG == true:
		# severity 0 shows all messages regardless of passed through severity
		var ORIGINAL_SEVERITY = DEBUG_SEVERITY
		if DEBUG_SEVERITY == 0:
			DEBUG_SEVERITY = SEVERITY
		if DEBUG_SEVERITY == SEVERITY:
			print("DEBUG_SEVERITY: ", SEVERITY, " | ", INFO)
			print(MESSAGE)
		DEBUG_SEVERITY = ORIGINAL_SEVERITY

# pass a string through the get_default() function and get the default from data/defaults.json
func get_default(setting):
	var file = FileAccess.open("res://data/defaults.json", FileAccess.READ)
	var DEFAULTS = JSON.parse_string(file.get_as_text())
	match setting:
		"WINDOW_TITLE":
			return DEFAULTS.WINDOW_TITLE
		"RNG_SEED":
			return DEFAULTS.RNG_SEED
		"RESOLUTION":
			return Vector2(DEFAULTS.RESOLUTION[0], DEFAULTS.RESOLUTION[1])
		"FONT_THEME":
			return DEFAULTS.FONT_THEME
		"GAME_DIFFICULTY":
			return DEFAULTS.GAME_DIFFICULTY
		"LEVEL_MATRIX":
			return DEFAULTS.LEVEL_MATRIX
		"LEVEL_NAME":
			return DEFAULTS.LEVEL_NAME
		"TILE_AMOUNT":
			return DEFAULTS.TILE_AMOUNT
		"COLOR_GRAY":
			return DEFAULTS.COLOR_GRAY
		"COLOR_BLUE":
			return DEFAULTS.COLOR_BLUE
		"COLOR_GREEN":
			return DEFAULTS.COLOR_GREEN
		"COLOR_ORANGE":
			return DEFAULTS.COLOR_ORANGE
		"COLOR_PURPLE":
			return DEFAULTS.COLOR_PURPLE
		"COLOR_RED":
			return DEFAULTS.COLOR_RED
		"COLOR_YELLOW":
			return DEFAULTS.COLOR_YELLOW
		"COLOR_BLACK":
			return DEFAULTS.COLOR_BLACK
		"COLOR_FLOOR":
			return DEFAULTS.COLOR_FLOOR
		"COLOR_GALAXY_1":
			return DEFAULTS.COLOR_GALAXY_1
		"COLOR_GALAXY_2":
			return DEFAULTS.COLOR_GALAXY_2
		"GAME_MODE":
			return DEFAULTS.GAME_MODE
		"INVERTED_MODE" :
			return DEFAULTS.INVERTED_MODE
		"ENABLE_JANK":
			return DEFAULTS.ENABLE_JANK

var pitch_scale = 1.0
var pitch_flip = 0
var previous_rng = 0
func sound_effect(SOUND):
	if MUTE_SOUNDS:
		return
	var SOUND_PLAYER = AudioStreamPlayer2D.new()
	SOUND_PLAYER.pitch_scale = 1.0
	SOUND_PLAYER.volume_db = 0.0
	if SOUND == "cube":
		if get_node_or_null("cube_sound"):
			return
		SOUND_PLAYER.name = "cube_sound"
		SOUND_PLAYER.stream = load("res://assets/sounds/cube_sound.mp3")
		if pitch_flip == 0:
			SOUND_PLAYER.pitch_scale = 1.0
			pitch_flip = 1
		else:
			SOUND_PLAYER.pitch_scale = 1.5
			pitch_flip = 0
		SOUND_PLAYER.volume_db = -4
	elif SOUND == "tile":
		SOUND_PLAYER = AudioStreamPlayer2D.new()
		SOUND_PLAYER.name = str("tile_sound",rng(0,3000))
		SOUND_PLAYER.stream = load("res://assets/sounds/tile_clear_sound.mp3")
		SOUND_PLAYER.volume_db = -4
	elif SOUND == "bomb":
		SOUND_PLAYER.name = str("bomb_sound",rng(0,3000))
		SOUND_PLAYER.stream = load("res://assets/sounds/bomb_sound.mp3")
		SOUND_PLAYER.volume_db = -8.0
	elif SOUND == "illegal":
		if get_node_or_null("illegal_sound"):
			return
		SOUND_PLAYER.name = "illegal_sound"
		SOUND_PLAYER.stream = load("res://assets/sounds/illegal_move.mp3")
		var NEW_RNG = rng_float(0.4,1.2)
		if NEW_RNG < 0.6:
			NEW_RNG = 0.5
		elif NEW_RNG < 0.8:
			NEW_RNG = 0.7
		elif NEW_RNG < 1.0:
			NEW_RNG = 0.9
		elif NEW_RNG > 1.0:
			NEW_RNG = 1.1
		SOUND_PLAYER.pitch_scale = NEW_RNG
	self.add_child(SOUND_PLAYER)
	SOUND_PLAYER.play()
	await SOUND_PLAYER.finished
	SOUND_PLAYER.queue_free()

# get the position of the cube
var CUBE_POSITION = Vector2()
func update_cube_position(position):
	CUBE_POSITION = position

func floor_check(pos_x, pos_y):
	var NODE_NAME = str(pos_x,"x",pos_y)
	var NEXT_COLOR
	#for node in get_node("VIEW_3D").get_children():
	if not get_node_or_null(str("VIEW_3D/",NODE_NAME)):
		debug_message("gd - floor_check() - couldn't find node",str("VIEW_3D/",NODE_NAME),2)
		return "stop"
	# if cube passes check, get the color of the next tile it is rolling into
	NEXT_COLOR = CURRENT_LEVEL[pos_y][pos_x]
	#print(NEXT_COLOR)
	return NEXT_COLOR

var LEVEL_COUNTER = 0
func json_counter():
	LEVEL_COUNTER = 0
	var dir = DirAccess.open(str("res://levels/",GAME_MODE,"/"))
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir():
				if file_name.get_extension() == "json":
					LEVEL_COUNTER += 1
					#print("Found file: " + file_name)
			file_name = dir.get_next()

# starting level
var LEVEL = 0
var amount_of_levels = 1
func update_level(amount):
	LEVEL += amount
	json_counter()
	if LEVEL < 1:
		LEVEL = LEVEL_COUNTER
	#CURRENT_LEVEL = []
	START_POSITION = Vector2(0,0)
	KEY_COUNT = 0
	AMOUNT_LEFT = 0
	KEY_COUNT_TOTAL = 0
	debug_message("update_level()", str("level = ", LEVEL), 1)

var CURRENT_GRAY = get_default("COLOR_GRAY")
var CURRENT_RED = get_default("COLOR_RED")
var CURRENT_GREEN = get_default("COLOR_GREEN")
var CURRENT_BLUE = get_default("COLOR_BLUE")
var CURRENT_YELLOW = get_default("COLOR_YELLOW")
var CURRENT_PURPLE = get_default("COLOR_PURPLE")
var CURRENT_ORANGE = get_default("COLOR_ORANGE")
var CURRENT_BLACK = get_default("COLOR_BLACK")
var CURRENT_FLOOR = get_default("COLOR_FLOOR")
var CURRENT_GALAXY_1 = get_default("COLOR_GALAXY_1")
var CURRENT_GALAXY_2 = get_default("COLOR_GALAXY_2")

func load_level():
	# if the CURRENT_LEVEL has data, set the LEVEL_MATRIX
	# this is so that when we redraw the tiles, the RNG is not set to a new value
	if CURRENT_LEVEL != []:
		LEVEL_MATRIX = CURRENT_LEVEL
		return
	# check if the level exists and load it as LEVEL_MATRIX
	var LEVEL_STRING
	if GAME_MODE == "Classic":
		LEVEL_STRING = str("res://levels/Classic/Classic_LEVEL_", LEVEL, ".json")
	elif GAME_MODE == "Puzzle":
		LEVEL_STRING = str("res://levels/Puzzle/Puzzle_LEVEL_", LEVEL, ".json")
	else:
		LEVEL_STRING = str("res://levels/Classic/Classic_LEVEL_", LEVEL, ".json")
	if not ResourceLoader.exists(LEVEL_STRING):
		LEVEL = 1
		load_level()
		return
	else:
		var file = FileAccess.open(LEVEL_STRING, FileAccess.READ)
		var level_data = JSON.parse_string(file.get_as_text())
		# check if level json even has level data
		if level_data.has("LEVEL_NAME"):
			LEVEL_NAME = str("Name: ",level_data.LEVEL_NAME)
			var CHARACTER_COUNT = 0
			for character in LEVEL_NAME:
				CHARACTER_COUNT += 1
				if CHARACTER_COUNT > 48:
					LEVEL_NAME = "name too long"
		else:
			LEVEL_NAME = str("unnamed_level_",rng(0,9999))
		if level_data.has("LEVEL_MATRIX"):
			LEVEL_MATRIX = level_data.LEVEL_MATRIX
			if LEVEL_MATRIX == []:
				LEVEL_MATRIX = get_default("LEVEL_MATRIX")
				AMOUNT_LEFT_LEVEL = get_default("TILE_AMOUNT")
		else:
			LEVEL_MATRIX = get_default("LEVEL_MATRIX")
		if level_data.has("GAME_MODE"):
			GAME_MODE = level_data.GAME_MODE
		else:
			GAME_MODE = get_default("GAME_MODE")
		if level_data.has("TILE_AMOUNT"):
			AMOUNT_LEFT_LEVEL = level_data.TILE_AMOUNT
		else:
			AMOUNT_LEFT_LEVEL = get_default("TILE_AMOUNT")
		CURRENT_GRAY = level_data.COLOR_1
		CURRENT_RED = level_data.COLOR_2
		CURRENT_GREEN = level_data.COLOR_3
		CURRENT_BLUE = level_data.COLOR_4
		CURRENT_YELLOW = level_data.COLOR_5
		CURRENT_PURPLE = level_data.COLOR_6
		CURRENT_ORANGE = level_data.COLOR_7
		CURRENT_BLACK = level_data.COLOR_8
		CURRENT_FLOOR = level_data.COLOR_FLOOR
		CURRENT_GALAXY_1 = level_data.COLOR_GALAXY_1
		CURRENT_GALAXY_2 = level_data.COLOR_GALAXY_2

# this will return COLOR and NAME
func get_cell_data(cell):
	# wonky things happen if you input a number that isn't double digits
	# so i check if the cell data is exactly 2 digits and work from there
	var CHARACTER_COUNT = 0
	# add 1 to the character count for every character in the current cell
	for character in str(cell):
		CHARACTER_COUNT += 1
	# if the character count is less than or greater than 2, skip it by setting a 00
	if not CHARACTER_COUNT == 2:
		cell = 00
	var COLOR
	var NAME
	var NEW_CELL = str(cell)
	var ATTRIBUTE
	# the json file has numbers that represent the colors/attributes listed here
	# placing the sequence [1,2,3,4] will output the following colors:
	# # gray, blue, red, green
	# we set them as an int to filter out any ascii or other stuff
	match int(str(cell).left(1)):
		0:
			COLOR = "null"
			NAME = "null"
		1:
			COLOR = CURRENT_GRAY
			#COLOR = get_default("COLOR_GRAY")
			NAME = "gray"
		2:
			COLOR = CURRENT_RED
			#COLOR = get_default("COLOR_RED")
			NAME = "red"
		3:
			COLOR = CURRENT_GREEN
			#COLOR = get_default("COLOR_GREEN")
			NAME = "green"
		4:
			COLOR = CURRENT_BLUE
			#COLOR = get_default("COLOR_BLUE")
			NAME = "blue"
		5:
			COLOR = CURRENT_YELLOW
			#COLOR = get_default("COLOR_YELLOW")
			NAME = "yellow"
		6:
			COLOR = CURRENT_PURPLE
			#COLOR = get_default("COLOR_PURPLE")
			NAME = "purple"
		7:
			COLOR = CURRENT_ORANGE
			#COLOR = get_default("COLOR_ORANGE")
			NAME = "orange"
		8:
			COLOR = CURRENT_BLACK
			#COLOR = get_default("COLOR_BLACK")
			NAME = "black"
		9:
			print("hopefully this never prints - gd - get_cell_data()")
			# when RNG is set, we need a way to keep track of what the new tile color is
			# so we get a random tile, and set the properties back in the level matrix
			var NEW_DATA = get_cell_data(rng(2,7))
			COLOR = NEW_DATA[0]
			NAME = NEW_DATA[1]
			NEW_CELL = NEW_DATA[2]
		_:
			COLOR = "null"
			NAME = "null"
	# set attributes to tiles from 2nd number in cell
	# we set them as an int to filter out any ascii or other stuff
	match int(str(cell).right(1)):
		0:
			ATTRIBUTE = "default"
		1:
			if COLOR == "null":
				ATTRIBUTE = "final_orb"
			else:
				ATTRIBUTE = "bomb"
		2:
			ATTRIBUTE = "detonator"
		3:
			ATTRIBUTE = "box"
		4:
			ATTRIBUTE = "key"
		7:
			ATTRIBUTE = "uncounted_tile"
		8:
			ATTRIBUTE = "single_use_tile"
		9:
			ATTRIBUTE = "start_position"
		_:
			ATTRIBUTE = "null"
	return [COLOR, NAME, NEW_CELL, ATTRIBUTE]

func spawn_box(x, y, COLOR):
	var NAME = str(x,"x",y,"_box")
	var NEW_BOX = BOX_MESH.instantiate()
	NEW_BOX.name = NAME
	NEW_BOX.scale = NEW_BOX.scale * 0.5
	NEW_BOX.position = Vector3(x,0.3,y)
	var material
	if COLOR == CURRENT_BLACK:
	#if COLOR == get_default("COLOR_BLACK"):
		material = load("res://assets/textures/block_3d_blank_texture.tres")
	else:
		material = load("res://assets/textures/block_3d_texture.tres")
	var new_material = material.duplicate()
	material.albedo_texture_force_srgb = true
	new_material.albedo_color = COLOR
	get_node(str("VIEW_3D/")).add_child(NEW_BOX)
	get_node(str("VIEW_3D/",NAME,"/MeshInstance3D")).mesh.surface_set_material(0, new_material)
	scale_thingy(NEW_BOX,0.3)

func spawn_key(COLOR,node_name):
	var material = load("res://assets/textures/key_texture.tres")
	var new_material = material.duplicate()
	new_material.albedo_color = COLOR
	get_node(str("VIEW_3D/",node_name)).mesh.surface_set_material(0, new_material)
	KEY_COUNT_TOTAL += 1

func scale_thingy(node, speed):
	var old_scale = node.scale
	node.scale = Vector3(0.01,0.01,0.01)
	node.show()
	var tween = create_tween().set_ease(Tween.EASE_OUT_IN)
	tween.tween_property(node,"scale",old_scale, speed)
	await tween.finished

func spawn_floor(pos):
	var COLOR = CURRENT_FLOOR
	var new_mesh = MeshInstance3D.new()
	new_mesh.name = str(pos.x,"x",pos.y,"_floor")
	new_mesh.position = Vector3(pos.x,-0.15,pos.y)
	new_mesh.mesh = PlaneMesh.new()
	new_mesh.mesh.size = Vector2(1,1)
	var material = StandardMaterial3D.new()
	material.albedo_color = COLOR
	new_mesh.mesh.surface_set_material(0, material)
	if get_node_or_null(str("VIEW_3D/", new_mesh.name)):
		return
	else:
		get_node("VIEW_3D").add_child(new_mesh)

func spawn_bomb(COLOR, node_name):
	var CURRENT_NODE = get_node(str("VIEW_3D/",node_name))
	var material = load("res://assets/textures/bomb_texture.tres")
	var new_material = material.duplicate()
	new_material.albedo_color = COLOR
	CURRENT_NODE.mesh.surface_set_material(0, new_material)

func spawn_detonator(x,y,COLOR):
	var new_mesh = MeshInstance3D.new()
	new_mesh.mesh = CylinderMesh.new()
	new_mesh.mesh.top_radius = 0.35
	new_mesh.mesh.bottom_radius = 0.4
	new_mesh.mesh.height = 0.1
	var material = StandardMaterial3D.new()
	new_mesh.name = str(x,"x",y,"_detonator")
	new_mesh.position = Vector3(x,0,y)
	material.albedo_color = COLOR
	get_node("VIEW_3D/").add_child(new_mesh)
	get_node(str("VIEW_3D/",new_mesh.name)).mesh.surface_set_material(0, material)
	var floor_material = StandardMaterial3D.new()
	floor_material.albedo_color = CURRENT_BLACK
	#floor_material.albedo_color = get_default("COLOR_BLACK")
	get_node(str("VIEW_3D/",x,"x",y)).mesh.surface_set_material(0, floor_material)

func spawn_final_orb(position,COLOR):
	if LEVEL_MATRIX == []:
		print("wtf")
		return
	var static_mesh = StaticBody3D.new()
	static_mesh.name = "final_orb"
	static_mesh.set_collision_layer_value(3,true)
	#static_mesh.position = position
	get_node("VIEW_3D").add_child(static_mesh)
	var finish_orb_mesh = MeshInstance3D.new()
	finish_orb_mesh.name = "finish_orb_mesh"
	finish_orb_mesh.mesh = SphereMesh.new()
	finish_orb_mesh.mesh.radius = 0.5
	finish_orb_mesh.mesh.resource_local_to_scene = true
	finish_orb_mesh.scale = Vector3(0.8,0.8,0.8)
	finish_orb_mesh.position = position
	static_mesh.add_child(finish_orb_mesh)
	var collision = CollisionShape3D.new()
	collision.name = "collision_box"
	collision.shape = BoxShape3D.new()
	#collision.disabled = false
	collision.position = finish_orb_mesh.position
	static_mesh.add_child(collision)
	var new_mat = StandardMaterial3D.new()
	if OS_CHECK == "desktop":
		var subviewport = load("res://assets/textures/marble_subviewport.tscn").instantiate()
		finish_orb_mesh.add_child(subviewport)
		new_mat.albedo_color = COLOR
		new_mat.albedo_texture = subviewport.get_texture()
	else:
		new_mat.albedo_color = COLOR
	finish_orb_mesh.mesh.material = new_mat
	finish_orb_mesh.rotation.z = 90

# this will spawn after the update_tiles() is ran
func spawn_tile(x, y, cell):
	# the get_cell_data() returns an array with html color codes and attributes
	var CELL_DATA = get_cell_data(cell)
	var COLOR = CELL_DATA[0]
	var ATTRIBUTE = CELL_DATA[3]
	# check the attribute for start position and final orb position before checking color data
	if ATTRIBUTE == "start_position":
		START_POSITION = Vector2(x,y)
	elif ATTRIBUTE == "final_orb":
		FINAL_ORB_POSITION = Vector3(x,0.5,y)
		COLOR = CURRENT_GRAY
		#COLOR = get_default("COLOR_GRAY")
		CURRENT_LEVEL[y][x] = "18"
		if GAME_MODE == "Puzzle":
			spawn_final_orb(FINAL_ORB_POSITION,COLOR)
	if COLOR == "null":
		return
	var CURRENT_TILE
	# create a VIEW_3D node to attach all 3d nodes to
	if not get_node_or_null("VIEW_3D"):
		var NODE_3D = Node3D.new()
		NODE_3D.name = str("VIEW_3D")
		self.add_child(NODE_3D)
	if get_node_or_null(str("VIEW_3D/",x,"x",y)):
		CURRENT_TILE = get_node(str("VIEW_3D/",x,"x",y))
		var tween2 = create_tween()
		tween2.tween_property(CURRENT_TILE,"scale",Vector3(0.01,0.01,0.01), 0.3)
		await tween2.finished
		#CURRENT_TILE.queue_free()
	else:
		CURRENT_TILE = NEW_TILE.duplicate(0)
		#CURRENT_TILE = MeshInstance3D.new()
		CURRENT_TILE.name = str(x,"x",y)
		CURRENT_TILE.mesh = BoxMesh.new()
		get_node("VIEW_3D").add_child(CURRENT_TILE)
	var material = StandardMaterial3D.new()
	material.albedo_color = COLOR
	#material.albedo_texture_force_srgb = true
	CURRENT_TILE.mesh.surface_set_material(0, material)
	spawn_floor(Vector2(x,y))
	var TILE_SCALE = 0.85
	var TILE_HEIGHT = 0.1
	# WARNING: changing the CURRENT_TILE.name var will break floor_check() function
	CURRENT_TILE.name = str(x,"x",y)
	CURRENT_TILE.scale = Vector3(TILE_SCALE, TILE_HEIGHT, TILE_SCALE)
	CURRENT_TILE.position = Vector3(x, -(TILE_HEIGHT / 2 + 0.03), y)
	match ATTRIBUTE:
		"uncounted_tile":
			pass
		"single_use_tile":
			pass
		"box":
			spawn_box(x,y,COLOR)
		"key":
			spawn_key(COLOR,CURRENT_TILE.name)
		"bomb":
			spawn_bomb(COLOR, CURRENT_TILE.name)
		"detonator":
			spawn_detonator(x,y,COLOR)
	await scale_thingy(CURRENT_TILE,0.4)

var STARTING_TILE_COUNT = 0
# this is the first function to run to spawn tiles
func update_tiles(MODE):
	# if reset, then delete all nodes and set CURRENT_LEVEL to nothing
	if MODE == "reset":
		remove_child(get_node("VIEW_3D"))
		CURRENT_LEVEL = []
		LEVEL_RESOLUTION = Vector2(0,0)
		KEY_COUNT = 0
		KEY_COUNT_TOTAL = 0
		LAST_CELL = ""
		SPHERE_COUNT = 0
		STARTING_TILE_COUNT = 0
		return
	load_level()
	# spawn all tiles in LEVEL_MATRIX
	if AMOUNT_LEFT_LEVEL != "0":
		AMOUNT_LEFT = int(AMOUNT_LEFT_LEVEL)
	else:
		AMOUNT_LEFT = 0
	var CURRENT_POS = Vector2(0,0)
	for row in LEVEL_MATRIX:
		for cell in row:
			# check if level has RNG values set
			var NEW_CELL = cell
			if str(cell).left(1) == "9":
				# if level has RNG values set, change the cell to the new RNG value
				NEW_CELL = str(str(rng(2, 7),str(cell).right(1)))
				# set the NEW_CELL value to the LEVEL_MATRIX
				LEVEL_MATRIX[CURRENT_POS.y][CURRENT_POS.x] = NEW_CELL
			# set CURRENT_LEVEL so that when tiles are updated, we are no longer regenerating RNG
			CURRENT_LEVEL = LEVEL_MATRIX
			spawn_tile(CURRENT_POS.x, CURRENT_POS.y, NEW_CELL)
			var COLOR_CHECK = get_cell_data(NEW_CELL)
			var CURRENT_COLOR = COLOR_CHECK[1]
			var ATTRIBUTE_CHECK = COLOR_CHECK[3]
			if CURRENT_COLOR == "gray":
				match ATTRIBUTE_CHECK:
					"default":
						pass
					"start_position":
						pass
					"single_use_tile":
						pass
					"uncounted_tile":
						pass
					_:
						if AMOUNT_LEFT_LEVEL == "0":
							AMOUNT_LEFT += 1
						else:
							STARTING_TILE_COUNT += 1
			elif CURRENT_COLOR != "gray":
				if CURRENT_COLOR != "null":
					if CURRENT_COLOR != "black":
						if ATTRIBUTE_CHECK != "uncounted_tile":
							if AMOUNT_LEFT_LEVEL == "0":
								AMOUNT_LEFT += 1
							else:
								STARTING_TILE_COUNT += 1
			# increment x so the next cell will be read correctly
			CURRENT_POS.x += 1
			if CURRENT_POS.x > LEVEL_RESOLUTION.x:
				LEVEL_RESOLUTION.x += 1
		# set x back to 0 and increment y to read the next row
		CURRENT_POS.x = 0
		CURRENT_POS.y += 1
		if CURRENT_POS.y > LEVEL_RESOLUTION.y:
			LEVEL_RESOLUTION.y += 1
	IS_READY = true
	emit_signal("signal_level_start")
	#if LEVEL_RESOLUTION.x > 15 or LEVEL_RESOLUTION.y > 15:
	#	CLOSE_UP_CAM = false
	#else:
	#	CLOSE_UP_CAM = true

var LAST_CELL = ""
var WAITING = false
func attribute_stuffs(CELL):
	var CELL_DATA = CURRENT_LEVEL[CELL.y][CELL.x]
	var CHECK_TILE = get_cell_data(CURRENT_LEVEL[CELL.y][CELL.x])
	var COLOR = CHECK_TILE[1]
	var ATTRIBUTE = CHECK_TILE[3]
	LAST_CELL = str(CELL.x,"x",CELL.y)
	match ATTRIBUTE:
		"uncounted_tile":
			if COLOR != "gray":
				spawn_tile(CELL.x,CELL.y,CELL_DATA)
				return
		"single_use_tile":
			if GAME_MODE == "Classic":
				if COLOR != "gray":
					CURRENT_LEVEL[CELL.y][CELL.x] = "18"
					spawn_tile(CELL.x,CELL.y,"18")
					amount_left_thingy()
					sound_effect("tile")
		"start_position":
			if GAME_MODE == "Classic":
				# check to see if tile is gray - without doing this, the level is rebuilt every step
				if COLOR != "gray":
					CURRENT_LEVEL[CELL.y][CELL.x] = "10"
					spawn_tile(CELL.x,CELL.y,"10")
					amount_left_thingy()
					sound_effect("tile")
			if GAME_MODE == "Puzzle":
				if COLOR != "gray":
					CURRENT_LEVEL[CELL.y][CELL.x] = str(str(CELL_DATA).left(1),0)
					spawn_tile(CELL.x,CELL.y,str(str(CELL_DATA).left(1),0))
		"default":
			if GAME_MODE == "Classic":
				# check to see if tile is gray
				if COLOR != "gray":
					sound_effect("tile")
					amount_left_thingy()
					CURRENT_LEVEL[CELL.y][CELL.x] = "10"
					spawn_tile(CELL.x,CELL.y,"10")
			if GAME_MODE == "Puzzle":
				if COLOR != "gray":
					CURRENT_LEVEL[CELL.y][CELL.x] = str(str(CELL_DATA).left(1),0)
					spawn_tile(CELL.x,CELL.y,str(str(CELL_DATA).left(1),0))
		"key":
			if KEY_COUNT < 1:
				reset_keys()
				KEY_COUNT = 0
			KEY_COUNT += 1
			if GAME_MODE == "Puzzle":
				CURRENT_LEVEL[CELL.y][CELL.x] = str(str(CELL_DATA).left(1),0)
				spawn_tile(CELL.x,CELL.y,str(str(CELL_DATA).left(1),0))
			if GAME_MODE == "Classic":
				sound_effect("tile")
				amount_left_thingy()
				CURRENT_LEVEL[CELL.y][CELL.x] = "10"
				spawn_tile(CELL.x,CELL.y,"10")
			debug_message("cube_3d.gd - fake_roll() - KEY_COUNT",KEY_COUNT,1)
		"box":
			if KEY_COUNT < 1:
				KEY_COUNT = 0
				sound_effect("illegal")
				return
			var NODE_NAME = str("VIEW_3D/",CELL.x,"x",CELL.y,"_box")
			if is_instance_valid(get_node(NODE_NAME)):
				if WAITING:
					return
				WAITING = true
				sound_effect("tile")
				var tween2 = create_tween()
				tween2.tween_property(get_node(NODE_NAME),"scale",Vector3(0.01,0.01,0.01), 0.2)
				await tween2.finished
				get_node(NODE_NAME).queue_free()
				WAITING = false
			else:
				return
			match GAME_MODE:
				"Classic":
					KEY_COUNT -= 1
					KEY_COUNT_TOTAL -= 1
					amount_left_thingy()
					CURRENT_LEVEL[CELL.y][CELL.x] = "10"
					spawn_tile(CELL.x,CELL.y,"10")
				"Puzzle":
					KEY_COUNT -= 1
					KEY_COUNT_TOTAL -= 1
					CURRENT_LEVEL[CELL.y][CELL.x] = str(str(CELL_DATA).left(1),0)
					spawn_tile(CELL.x, CELL.y, str(str(CELL_DATA).left(1),0))
		"detonator":
			sound_effect("tile")
			CURRENT_LEVEL[CELL.y][CELL.x] = "10"
			spawn_tile(CELL.x,CELL.y,"10")
			emit_signal("signal_detonator", COLOR)
			var node = get_node(str("VIEW_3D/",CELL.x,"x",CELL.y,"_detonator"))
			var tween = create_tween()
			tween.tween_property(node,"scale",Vector3(0.01,0.01,0.01),0.3)
			await tween.finished
			node.queue_free()
		"bomb":
			print("bomb detected: ", COLOR)
		"final_orb":
			pass

func os_checker():
	match OS.get_name():
		"Windows", "macOS","Linux", "FreeBSD", "NetBSD", "OpenBSD", "BSD":
			OS_CHECK = "desktop"
		"Android", "iOS", "Web":
			OS_CHECK = "mobile"
		"Web":
			OS_CHECK = "mobile"
		_:
			OS_CHECK = "mobile"

var BOMB_TILES : Array
var FINISHED_CHECK = true
func _on_signal_detonator(COLOR):
	var FOUND_NODE = false
	amount_left_thingy()
	var temp_x = 0
	var temp_y = 0
	for row in CURRENT_LEVEL:
		for cell in row:
			var info = get_cell_data(cell)
			var COLOR_MATCH = info[1]
			var ATTRIBUTE_MATCH = info[3]
			if COLOR_MATCH == "black":
				if ATTRIBUTE_MATCH == "bomb":
					spawn_tile(temp_x,temp_y,10)
					CURRENT_LEVEL[temp_y][temp_x] = 10
			if COLOR_MATCH == COLOR:
				if ATTRIBUTE_MATCH == "bomb":
					FOUND_NODE = true
					CURRENT_LEVEL[temp_y][temp_x] = 10
					spawn_tile(temp_x,temp_y,10)
					amount_left_thingy()
					var up = Vector2(temp_x,temp_y - 1)
					var middle = Vector2(temp_x,temp_y)
					var down = Vector2(temp_x, temp_y + 1)
					#var left = Vector2(temp_x - 1, temp_y)
					#var right = Vector2(temp_x + 1, temp_y)
					for i in [up + Vector2(-1,0),up,up + Vector2(1,0),middle + Vector2(-1,0),middle,middle + Vector2(1,0),down + Vector2(-1,0),down,down + Vector2(1,0)]:
						BOMB_TILES.append(i)
						if get_node_or_null(str("VIEW_3D/",i.x,"x",i.y)):
							var tile_data = get_cell_data(CURRENT_LEVEL[i.y][i.x])
							var potential_color = tile_data[1]
							var potential_attribute = tile_data[3]
							if potential_attribute == "key":
								KEY_COUNT_TOTAL -= 1
							match potential_color:
								"gray":
									match potential_attribute:
										"default","start_position","single_use_tile","uncounted_tile":
											pass
										_:
											amount_left_thingy()
								"black":
									pass
								_:
									if potential_attribute == "uncounted_tile":
										pass
									else:
										amount_left_thingy()
							sound_effect("bomb")
							PAUSE = true
							#if get_node_or_null(str("VIEW_3D/",i.x,"x",i.y,"_box")):
							#	var node = get_node(str("VIEW_3D/",i.x,"x",i.y,"_box"))
							#	var tween = create_tween()
							#	tween.tween_property(node,"scale",Vector3(0.01,0.01,0.01),0.3)
							#	#await tween.finished
							#	#node.queue_free()
							#if get_node_or_null(str("VIEW_3D/",i.x,"x",i.y,"_detonator")):
							#	var node = get_node(str("VIEW_3D/",i.x,"x",i.y,"_detonator"))
							#	var tween = create_tween()
							#	tween.tween_property(node,"scale",Vector3(0.01,0.01,0.01),0.3)
							#	await tween.finished
							#	#node.queue_free()
							#if potential_attribute == "single_use_tile":
							#	CURRENT_LEVEL[i.y][i.x] = "18"
							#else:
							#	CURRENT_LEVEL[i.y][i.x] = "10"
							CURRENT_LEVEL[i.y][i.x] = "18"
							spawn_tile(i.x,i.y,CURRENT_LEVEL[i.y][i.x])
							PAUSE = false
			if FOUND_NODE == true:
				return
			temp_x += 1
		temp_x = 0
		temp_y += 1

func amount_left_thingy():
	#if AMOUNT_LEFT_LEVEL != "0":
	#	STARTING_TILE_COUNT -= 1
	AMOUNT_LEFT -= 1
	print("AMOUNT_LEFT: ", AMOUNT_LEFT)
	print("STARTING_TILE_COUNT: ", STARTING_TILE_COUNT)
	if AMOUNT_LEFT_LEVEL != "0":
		if AMOUNT_LEFT >= STARTING_TILE_COUNT:
			spawn_rng()

var bad_tile = false
func spawn_rng():
	var VALID_TILE = false
	var pos_x = 0
	var pos_y = 0
	while VALID_TILE == false:
		pos_x = rng(0,LEVEL_RESOLUTION.x)
		pos_y = rng(0,LEVEL_RESOLUTION.y)
		var NODE_NAME = str(pos_x,"x",pos_y)
		if get_node_or_null(str("VIEW_3D/",NODE_NAME)):
			var CELL = CURRENT_LEVEL[pos_y][pos_x]
			if str(CELL) == "10" or CELL == "19":
				for cell in BOMB_TILES:
					if Vector2(pos_x,pos_y) == cell:
						bad_tile == true
				if bad_tile == false:
					VALID_TILE = true
					BOMB_TILES = []
	var NEW_RNG = str(rng(2,7),0)
	print(NEW_RNG)
	CURRENT_LEVEL[pos_y][pos_x] = NEW_RNG
	spawn_tile(pos_x,pos_y,NEW_RNG)

func _ready():
	os_checker()
	signal_detonator.connect(_on_signal_detonator)
	if not DirAccess.dir_exists_absolute("user://"):
		DirAccess.make_dir_absolute("user://")
	update_level(1)

var FINAL_ORB_POSITION: Vector3
var SPHERE_COUNT = 0
func _process(delta):
	RNG_COUNTER += delta
	if IS_READY == true:
		if AMOUNT_LEFT <= 0:
			AMOUNT_LEFT = 0
			SPHERE_COUNT += 1
			if SPHERE_COUNT == 1:
				spawn_final_orb(Vector3(FINAL_ORB_POSITION),get_cell_data(str(rng(2,7),0))[0])
