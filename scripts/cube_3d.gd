extends CharacterBody3D

@onready var pivot = $Pivot
@onready var mesh = $Pivot/MeshInstance3D
var cube_size = 1.0
var speed = 6.0
var rolling = false
var CURRENT_ORIENTATION = Vector3(0,0,0)
var CURRENT_ORIENTATION_COLOR
var FUTURE_ORIENTATION = Vector3(0,0,0)
var FUTURE_ORIENTATION_COLOR
var ENABLE_TRANSFORM_INFO = true

func set_cube_material():
	if GLOBALS.GAME_DIFFICULTY == "normal":
		var material = load("res://assets/textures/cube_3d_easy.tres")
		if GLOBALS.INVERTED_MODE == "true":
			material = load("res://assets/textures/cube_3d_easy_inverted.tres")
		else:
			material = load("res://assets/textures/cube_3d_easy.tres")
		mesh.set_surface_override_material(0, material)
	elif GLOBALS.GAME_DIFFICULTY == "hard":
		var material = load("res://assets/textures/cube_3d_hard.tres")
		if GLOBALS.INVERTED_MODE == "true":
			material = load("res://assets/textures/cube_3d_hard_inverted.tres")
		else:
			material = load("res://assets/textures/cube_3d_hard.tres")
		mesh.set_surface_override_material(0, material)
	elif GLOBALS.GAME_DIFFICULTY == "invisible":
		var material = load("res://assets/textures/cube_3d_invisible.tres")
		mesh.set_surface_override_material(0, material)

# the input passed through to match_orientation is a Vector3 with xyz containting a Vector3
func match_orientation(transform_basis):
	var RETURN_COLOR = "null"
	if transform_basis.x.y == 1:
		RETURN_COLOR = "yellow"
	elif transform_basis.x.y == -1:
		RETURN_COLOR = "red"
	if transform_basis.y.y == 1:
		RETURN_COLOR = "blue"
	elif transform_basis.y.y == -1:
		RETURN_COLOR = "orange"
	if transform_basis.z.y == 1:
		RETURN_COLOR = "green"
	elif transform_basis.z.y == -1:
		RETURN_COLOR = "purple"
	if RETURN_COLOR == "null":
		GLOBALS.debug_message("cube_3d.gd - match_orientation()", str(transform_basis), 3)
	return RETURN_COLOR

func print_transforms(state,transform_basis,dir):
	if not ENABLE_TRANSFORM_INFO:
		return
	print("----------")
	print("Direction: ",dir)
	if state == "start":
		print("Starting Position:")
	elif state == "end":
		print("Ending Position:")
	print(str("x: ",GLOBALS.round_vect3(transform_basis).x))
	print(str("y: ",GLOBALS.round_vect3(transform_basis).y))
	print(str("z: ",GLOBALS.round_vect3(transform_basis).z))

# before actually rolling, we want check for the color of the tile we are rolling into
# so this junk below will create a fake cube and roll it to find if we can even land there
func fake_roll(dir):
	if rolling:
		#CAN_ROLL = "false"
		return false
	rolling = true
	# create a FAKE_PIVOT mesh
	var FAKE_PIVOT = Node3D.new()
	FAKE_PIVOT.name = "FAKE_PIVOT"
	pivot.add_child(FAKE_PIVOT)
	# create an invisible mesh
	var FAKE_MESH = MeshInstance3D.new()
	FAKE_MESH.name = "INVISIBLE_CUBE"
	FAKE_PIVOT.add_child(FAKE_MESH)
	# set the properties from the original mesh and pivot
	FAKE_MESH.position = mesh.position
	FAKE_MESH.global_transform.basis = mesh.global_transform.basis
	print_transforms("start",FAKE_MESH.global_transform.basis,dir)
	FAKE_MESH.rotation_degrees = GLOBALS.round_vect3(mesh.rotation_degrees)
	# do the stuffs to make the fake pivot move
	#FAKE_PIVOT.translate(dir * cube_size / 2)
	FAKE_MESH.global_translate(-dir * cube_size / 2)
	var axis = dir.cross(Vector3.DOWN)
	var tween = create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
	tween.tween_property(FAKE_PIVOT, "transform",FAKE_PIVOT.transform.rotated_local(axis, PI/2), 0)
	await tween.finished
	var b = FAKE_MESH.global_transform.basis
	FAKE_PIVOT.transform = Transform3D.IDENTITY
	FAKE_MESH.position = Vector3(0, cube_size / 2, 0)
	FAKE_MESH.global_transform.basis = b
	print_transforms("end",FAKE_MESH.global_transform.basis,dir)
	# this will get the orientation of the FAKE_MESH after it has moved around and stuffs
	FUTURE_ORIENTATION_COLOR = match_orientation(FAKE_MESH.global_transform.basis)
	# we then delete the FAKE_PIVOT and FAKE_MESH
	FAKE_PIVOT.queue_free()
	# we need to get the properties of the tile we are moving into
	# this will create an x y position of the tile we are trying to move to
	var CELL = Vector2(GLOBALS.CUBE_POSITION.x + dir.x, GLOBALS.CUBE_POSITION.y + dir.z)
	# we then take that CELL_DATA and get color and attributes of the tile we are trying to move to
	var CHECK_TILE = GLOBALS.get_cell_data(GLOBALS.CURRENT_LEVEL[CELL.y][CELL.x])
	# if the tile color is gray, we cheat and say that the tile color is the color of our cube
	if CHECK_TILE[1] == "gray":
		FUTURE_ORIENTATION_COLOR = CHECK_TILE[1]
		#CHECK_COLOR[1] = FUTURE_ORIENTATION_COLOR
	rolling = false
	# if the color of the tile we are trying to move into is the same as what our cube will be
	if FUTURE_ORIENTATION_COLOR == CHECK_TILE[1]:
		return true
	else:
		GLOBALS.sound_effect("illegal")
		GLOBALS.debug_message("cube_3d.gd - fake_roll() - CHECK_COLOR",CHECK_TILE,2)
		return false

func roll(dir):
	# Do nothing if we're currently rolling.
	if rolling:
		return
	# Cast a ray to check for obstacles
	var space = get_world_3d().direct_space_state
	var ray = PhysicsRayQueryParameters3D.create(mesh.global_position,
			mesh.global_position + dir * cube_size, collision_mask, [self])
	var collision = space.intersect_ray(ray)
	if collision:
		match int(collision.normal.x):
			-1:
				GLOBALS.debug_message("cube_3d.gd - roll()","right side collision detected", 2)
			1:
				GLOBALS.debug_message("cube_3d.gd - roll()","left side collision detected", 2)
		match int(collision.normal.z):
			-1:
				GLOBALS.debug_message("cube_3d.gd - roll()","bottom side collision detected", 2)
			1:
				GLOBALS.debug_message("cube_3d.gd - roll()","top side collision detected", 2)
		return
	GLOBALS.sound_effect("cube")
	rolling = true
	# Step 1: Offset the pivot.
	pivot.translate(dir * cube_size / 2)
	mesh.global_translate(-dir * cube_size / 2)
	# Step 2: Animate the rotation.
	var axis = dir.cross(Vector3.DOWN)
	var tween = create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
	tween.tween_property(pivot, "transform",pivot.transform.rotated_local(axis, PI/2), 1 / speed)
	await tween.finished
	# Step 3: Finalize the movement and reset the offset.
	position += dir * cube_size
	var b = mesh.global_transform.basis
	pivot.transform = Transform3D.IDENTITY
	mesh.position = Vector3(0, cube_size / 2, 0)
	mesh.global_transform.basis = b
	CURRENT_ORIENTATION_COLOR = match_orientation(mesh.global_transform.basis)
	GLOBALS.debug_message("cube_3d.gd - roll() - CURRENT_ORIENTATION_COLOR", CURRENT_ORIENTATION_COLOR,1)
	rolling = false
	GLOBALS.update_cube_position(Vector2(int(position.x), int(position.z)))

func reset_pos():
	GLOBALS.update_cube_position(Vector2(GLOBALS.START_POSITION.x,GLOBALS.START_POSITION.y))
	mesh.rotation_degrees = Vector3(0,0,0)
	GLOBALS.PAUSE = true
	position = Vector3(GLOBALS.START_POSITION.x,0,GLOBALS.START_POSITION.y)
	scale = Vector3(0.01,0.01,0.01)
	GLOBALS.PAUSE = true
	var tween2 = create_tween()
	tween2.tween_property(self,"scale",Vector3(1,1,1),0.9)
	await tween2.finished
	GLOBALS.PAUSE = false
	
	GLOBALS.PAUSE = false

func _ready():
	set_cube_material()
	GLOBALS.KEY_COUNT = 0
	position = Vector3(GLOBALS.START_POSITION.x,0,GLOBALS.START_POSITION.y)
	GLOBALS.update_cube_position(Vector2(position.x,position.z))
	reset_pos()

var ORIGINAL_SPEED = speed
var LAST_MODE = GLOBALS.GAME_DIFFICULTY
var LAST_INVERTED = str(GLOBALS.INVERTED_MODE)
var TIMER = 0
# sloppy input management
func _physics_process(_delta):
	if GLOBALS.GAME_DIFFICULTY != LAST_MODE:
		LAST_MODE = GLOBALS.GAME_DIFFICULTY
		set_cube_material()
	if GLOBALS.INVERTED_MODE != LAST_INVERTED:
		LAST_INVERTED = GLOBALS.INVERTED_MODE
		set_cube_material()
	if Input.is_action_just_pressed("reset"):
		if GLOBALS.PAUSE == false:
			# uncomment the line below to force the RNG to be the same each reset
			GLOBALS.debug_message("cube_3d.gd", "reset button pressed", 1)
			GLOBALS.update_tiles("reset")
			GLOBALS.update_tiles("3d")
			GLOBALS.emit_signal("signal_level_start")
			reset_pos()
	if Input.is_action_just_pressed("level_next"):
		if GLOBALS.PAUSE == false:
			GLOBALS.update_level(1)
			GLOBALS.update_tiles("reset")
			GLOBALS.update_tiles("3d")
			GLOBALS.emit_signal("signal_level_start")
			# set the position and then pass position to GLOBALS.update_cube_position
			# if we don't do this, the cube can end up on a bad tile
			reset_pos()
	if Input.is_action_just_pressed("level_previous"):
		if GLOBALS.PAUSE == false:
			GLOBALS.update_level(-1)
			GLOBALS.update_tiles("reset")
			GLOBALS.update_tiles("3d")
			GLOBALS.emit_signal("signal_level_start")
			reset_pos()
	if GLOBALS.PAUSE:
		return
	speed = ORIGINAL_SPEED
	if Input.is_action_pressed("hmls_shift"):
		speed = speed * 1.5
	var DIR = Vector3.ZERO
	if Input.is_action_pressed("forward"):
		match GLOBALS.ROTATION_COUNT:
			1:
				DIR = Vector3.FORWARD
			2:
				DIR = Vector3.LEFT
			3:
				DIR = Vector3.BACK
			4:
				DIR = Vector3.RIGHT
	if Input.is_action_pressed("back"):
		match GLOBALS.ROTATION_COUNT:
			1:
				DIR = Vector3.BACK
			2:
				DIR = Vector3.RIGHT
			3:
				DIR = Vector3.FORWARD
			4:
				DIR = Vector3.LEFT
	if Input.is_action_pressed("right"):
		match GLOBALS.ROTATION_COUNT:
			1:
				DIR = Vector3.RIGHT
			2:
				DIR = Vector3.FORWARD
			3:
				DIR = Vector3.LEFT
			4:
				DIR = Vector3.BACK
	if Input.is_action_pressed("left"):
		match GLOBALS.ROTATION_COUNT:
			1:
				DIR = Vector3.LEFT
			2:
				DIR = Vector3.BACK
			3:
				DIR = Vector3.RIGHT
			4:
				DIR = Vector3.FORWARD
	if DIR != Vector3.ZERO:
		# check if there is even a tile in the LEVEL_MATRIX to move to
		match str(GLOBALS.floor_check(GLOBALS.CUBE_POSITION.x + DIR.x, GLOBALS.CUBE_POSITION.y + DIR.z)):
			"stop":
				GLOBALS.sound_effect("illegal")
				return
		# the CAN_ROLL variable is set after the fake cube checks if the orientation matches the tile
		var CAN_ROLL = await fake_roll(DIR)
		if CAN_ROLL == false:
			return
		# we then check if the tile has an attribute (bombs, keys, etc)
		GLOBALS.attribute_stuffs(Vector2(GLOBALS.CUBE_POSITION.x + DIR.x, GLOBALS.CUBE_POSITION.y + DIR.z))
		# finally we roll into the tile
		roll(DIR)
		# add some RNG so every spawn is different
		GLOBALS.RNG_COUNTER += 1
