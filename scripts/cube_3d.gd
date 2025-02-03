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
var ENABLE_TRANSFORM_INFO = false

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

# before actually rolling, we want check for the color of the tile we are rolling into
# so this junk below will create a fake cube and roll it to find if we can even land there
func fake_roll(dir):
	if rolling:
		return false
	rolling = true
	var FAKE_PIVOT = pivot.duplicate()
	FAKE_PIVOT.name = "FAKE_PIVOT"
	FAKE_PIVOT.hide()
	pivot.add_child(FAKE_PIVOT)
	var FAKE_MESH = mesh.duplicate()
	FAKE_MESH.name = "INVISIBLE_CUBE"
	FAKE_PIVOT.add_child(FAKE_MESH)
	var axis = dir.cross(Vector3.DOWN)
	FAKE_PIVOT.transform = FAKE_PIVOT.transform.rotated_local(axis, PI/2)
	FUTURE_ORIENTATION_COLOR = match_orientation(FAKE_MESH.global_transform.basis)
	FAKE_PIVOT.queue_free()
	var CELL = Vector2(GLOBALS.CUBE_POSITION.x + dir.x, GLOBALS.CUBE_POSITION.y + dir.z)
	var CHECK_TILE = GLOBALS.get_cell_data(GLOBALS.CURRENT_LEVEL[CELL.y][CELL.x])
	if CHECK_TILE[1] == "gray":
		FUTURE_ORIENTATION_COLOR = CHECK_TILE[1]
	rolling = false
	if FUTURE_ORIENTATION_COLOR == CHECK_TILE[1]:
		return true
	else:
		GLOBALS.sound_effect("illegal")
		GLOBALS.debug_message("cube_3d.gd - fake_roll() - CHECK_COLOR",CHECK_TILE,2)
		return false

func dir_thingy(direction, rotation_data):
	var normalized_rotation = Basis()
	normalized_rotation.x = GLOBALS.round_vect3(rotation_data.x)
	normalized_rotation.y = GLOBALS.round_vect3(rotation_data.y)
	normalized_rotation.z = GLOBALS.round_vect3(rotation_data.z)
	var axis_names = ["x", "y", "z"]
	var color_pairs = [
		[GLOBALS.CURRENT_RED, GLOBALS.CURRENT_YELLOW],
		[GLOBALS.CURRENT_ORANGE, GLOBALS.CURRENT_BLUE],
		[GLOBALS.CURRENT_PURPLE, GLOBALS.CURRENT_GREEN]
	]
	var color_left
	var color_right
	var color_top
	var color_bottom
	var color_face
	var color_back
	for axis_index in range(3):
		var axis_name = axis_names[axis_index]
		var rotation_vector = normalized_rotation[axis_name]
		for component_index in range(3):
			var component_value = rotation_vector[component_index]
			if component_value == 1:
				if component_index == 0:
					color_left = color_pairs[axis_index][0]
					color_right = color_pairs[axis_index][1]
				elif component_index == 1:
					color_top = color_pairs[axis_index][1]
					color_bottom = color_pairs[axis_index][0]
				elif component_index == 2:
					color_face = color_pairs[axis_index][1]
					color_back = color_pairs[axis_index][0]
			elif component_value == -1:
				if component_index == 0:
					color_left = color_pairs[axis_index][1]
					color_right = color_pairs[axis_index][0]
				elif component_index == 1:
					color_top = color_pairs[axis_index][0]
					color_bottom = color_pairs[axis_index][1]
				elif component_index == 2:
					color_face = color_pairs[axis_index][0]
					color_back = color_pairs[axis_index][1]
	GLOBALS.current_colors[0] = color_left
	GLOBALS.current_colors[1] = color_right
	GLOBALS.current_colors[2] = color_top
	GLOBALS.current_colors[3] = color_bottom
	GLOBALS.current_colors[4] = color_face
	GLOBALS.current_colors[5] = color_back
	GLOBALS.print_colors()

func roll(dir):
	# Do nothing if we're currently rolling.
	if rolling:
		return
	# Cast a ray to check for obstacles
	var space = get_world_3d().direct_space_state
	var ray = PhysicsRayQueryParameters3D.create(mesh.global_position,mesh.global_position + dir * cube_size, collision_mask, [self])
	var main_collision = space.intersect_ray(ray)
	if space.intersect_ray(ray):
		if main_collision.collider.name == "final_orb":
			#GLOBALS.emit_signal("signal_level_end")
			GLOBALS.signal_level_end.emit()
		match int(main_collision.normal.x):
			-1:
				GLOBALS.debug_message("cube_3d.gd - roll()","right side collision detected", 2)
			1:
				GLOBALS.debug_message("cube_3d.gd - roll()","left side collision detected", 2)
		match int(main_collision.normal.z):
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
	dir_thingy(dir,b)
	#print(GLOBALS.round_vect4(b.get_rotation_quaternion()))
	pivot.transform = Transform3D.IDENTITY
	mesh.position = Vector3(0, cube_size / 2, 0)
	#mesh.global_transform.basis = b
	mesh.global_transform.basis = Basis(GLOBALS.round_vect3(b.x),GLOBALS.round_vect3(b.y),GLOBALS.round_vect3(b.z))
	CURRENT_ORIENTATION_COLOR = match_orientation(mesh.global_transform.basis)
	GLOBALS.debug_message("cube_3d.gd - roll() - CURRENT_ORIENTATION_COLOR", CURRENT_ORIENTATION_COLOR,1)
	rolling = false
	GLOBALS.update_cube_position(Vector2(int(position.x), int(position.z)))

func reset_pos():
	dir_thingy(Vector3.ZERO, Basis(Vector3(1,0,0),Vector3(0,1,0),Vector3(0,0,1)))
	#await dir_thingy(Vector3.ZERO, mesh.global_transform.basis)
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

func _on_signal_level_end():
	print("finish cube_3d stuffs for level end")

func _ready():
	#print(GLOBALS.round_vect4(mesh.global_transform.basis.get_rotation_quaternion()))
	var new_mat = StandardMaterial3D.new()
	var subviewport = $SubViewport
	new_mat.albedo_color = "#ffffff"
	new_mat.albedo_texture = subviewport.get_texture()
	$Pivot/MeshInstance3D.mesh.material = new_mat
	GLOBALS.signal_level_end.connect(_on_signal_level_end)
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
	if GLOBALS.LEVEL_END:
		return
	if GLOBALS.RESET_LEVEL == true:
		GLOBALS.RESET_LEVEL = false
		reset_pos()
	if Input.is_action_just_pressed("reset"):
		if GLOBALS.PAUSE == false:
			# uncomment the line below to force the RNG to be the same each reset
			GLOBALS.debug_message("cube_3d.gd", "reset button pressed", 1)
			GLOBALS.update_tiles("reset")
			GLOBALS.update_tiles("3d")
			reset_pos()
	if Input.is_action_just_pressed("level_next"):
		if GLOBALS.PAUSE == false:
			GLOBALS.update_level(1)
			GLOBALS.update_tiles("reset")
			GLOBALS.update_tiles("3d")
			# set the position and then pass position to GLOBALS.update_cube_position
			# if we don't do this, the cube can end up on a bad tile
			reset_pos()
	if Input.is_action_just_pressed("level_previous"):
		if GLOBALS.PAUSE == false:
			GLOBALS.update_level(-1)
			GLOBALS.update_tiles("reset")
			GLOBALS.update_tiles("3d")
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
