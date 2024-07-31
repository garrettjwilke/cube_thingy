extends Node3D
@onready var CAMERA_NODE = $Camera3D
var cam_offset
var cam_rotation = Vector3(-55,0,0)
var cam_speed = 3
var CAN_ROTATE = true

@onready var SKY_MATERIAL = $WorldEnvironment.environment.sky.sky_material
@onready var OUTLINE_SHADER = get_node("Camera3D/shader_mobius").mesh.material

func rotate_view(input):
	GLOBALS.ROTATION_COUNT += input
	if GLOBALS.ROTATION_COUNT > 4:
		GLOBALS.ROTATION_COUNT = 1
	if GLOBALS.ROTATION_COUNT < 1:
		GLOBALS.ROTATION_COUNT = 4
	var ROTATION_DEGREES
	if input == 1:
		ROTATION_DEGREES = 90
	elif input == -1:
		ROTATION_DEGREES = -90
	elif input == 0:
		ROTATION_DEGREES = 0
	cam_rotation.y += ROTATION_DEGREES

var rotation_count = 0
func rotate_skybox():
	var speed = 0.00015
	rotation_count += 0.01
	if rotation_count < 4:
		$WorldEnvironment.environment.sky_rotation.x += speed
		$WorldEnvironment.environment.sky_rotation.y += speed
		$WorldEnvironment.environment.sky_rotation.z -= speed
	if rotation_count > 4:
		$WorldEnvironment.environment.sky_rotation.x += speed * 2
		$WorldEnvironment.environment.sky_rotation.y += speed * 2
		$WorldEnvironment.environment.sky_rotation.z -= speed * 2
	if rotation_count > 8:
		rotation_count = 0

func _on_signal_level_end():
	print("do view_3d stuffs for level end")
	SKY_MATERIAL.set("shader_parameter/color_1",Vector3(0.2, 0.2, 0.2))
	#SKY_MATERIAL.set("shader_parameter/color_1",Vector3(0.5, 0.5, 0.4))
	SKY_MATERIAL.set("shader_parameter/color_2",Vector3(0.1,0.1,0.1))

func _ready():
	GLOBALS.signal_level_end.connect(_on_signal_level_end)
	rotate_view(0)
	GLOBALS.update_tiles("3d")
	# after updating the level tiles, set the cube position
	var CUBE = get_node("Cube")
	CUBE.position = Vector3(GLOBALS.START_POSITION.x,0,GLOBALS.START_POSITION.y)
	GLOBALS.update_cube_position(Vector2(CUBE.position.x, CUBE.position.z))
	if GLOBALS.ENABLE_SHADERS == true:
		$Camera3D/DirectionalLight3D.light_energy = 1.5
	else:
		$Camera3D/DirectionalLight3D.light_energy = 1.3

var TIMER = 0
var COLOR_GALAXY_1
var COLOR_GALAXY_2
#@onready var COLOR_GALAXY_1 = str("#",SKY_MATERIAL.get("shader_parameter/color_1").to_html(false))
#@onready var COLOR_GALAXY_2 = str("#",SKY_MATERIAL.get("shader_parameter/color_2").to_html(false))
func _process(delta):
	if COLOR_GALAXY_1 != GLOBALS.CURRENT_GALAXY_1 or COLOR_GALAXY_2 != GLOBALS.CURRENT_GALAXY_2:
		COLOR_GALAXY_1 = GLOBALS.CURRENT_GALAXY_1
		COLOR_GALAXY_2 = GLOBALS.CURRENT_GALAXY_2
		var TEMP_COLOR_1 = Color(str(COLOR_GALAXY_1).right(6))
		var TEMP_COLOR_2 = Color(str(COLOR_GALAXY_2).right(6))
		SKY_MATERIAL.set("shader_parameter/color_1",TEMP_COLOR_1)
		SKY_MATERIAL.set("shader_parameter/color_2",TEMP_COLOR_2)
	if GLOBALS.OS_CHECK == "mobile":
		if GLOBALS.ENABLE_SHADERS == true:
			GLOBALS.ENABLE_SHADERS = false
	rotate_skybox()
	if Input.is_action_just_pressed("ui_undo"):
		if GLOBALS.ENABLE_SHADERS:
			GLOBALS.ENABLE_SHADERS = false
		else:
			GLOBALS.ENABLE_SHADERS = true
	if GLOBALS.ENABLE_SHADERS:
		if not $Camera3D/shader_mobius.is_visible():
			$Camera3D/DirectionalLight3D.light_energy = 1.5
			$Camera3D/shader_mobius.show()
	else:
		if $Camera3D/shader_mobius.is_visible():
			$Camera3D/shader_mobius.hide()
			$Camera3D/DirectionalLight3D.light_energy = 1.3
	if Input.is_action_just_pressed("CAM_ROTATE_LEFT"):
		if GLOBALS.INVERT_CAM == true:
			rotate_view(1)
		else:
			rotate_view(-1)
	if Input.is_action_just_pressed("CAM_ROTATE_RIGHT"):
		if GLOBALS.INVERT_CAM == true:
			rotate_view(-1)
		else:
			rotate_view(1)
	match GLOBALS.ROTATION_COUNT:
		1:
			cam_offset = Vector3(3, 8, 5)
		2:
			cam_offset = Vector3(5, 8, -3)
		3:
			cam_offset = Vector3(-3, 8, -5)
		4:
			cam_offset = Vector3(-5, 8, 3)
		_:
			cam_offset = Vector3(3, 8, 5)
			GLOBALS.ROTATION_COUNT = 1
	if GLOBALS.CLOSE_UP_CAM == false:
		cam_offset = cam_offset * 3.2
	$Camera3D.position = lerp($Camera3D.position, $Cube.position + cam_offset, cam_speed * delta)
	$Camera3D.rotation_degrees = lerp($Camera3D.rotation_degrees, cam_rotation, cam_speed * delta)
	if Input.is_action_just_pressed("cam_swap"):
		if GLOBALS.CLOSE_UP_CAM == true:
			GLOBALS.CLOSE_UP_CAM = false
		else:
			GLOBALS.CLOSE_UP_CAM = true
