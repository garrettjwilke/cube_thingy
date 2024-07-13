extends Node3D
@onready var CAMERA_NODE = $Camera3D

var cam_offset
var cam_rotation = Vector3(-55,0,0)
var cam_speed = 3

var CAN_ROTATE = true

func rotate_view(input):
	hmls.ROTATION_COUNT += input
	if hmls.ROTATION_COUNT > 4:
		hmls.ROTATION_COUNT = 1
	if hmls.ROTATION_COUNT < 1:
		hmls.ROTATION_COUNT = 4
	var ROTATION_DEGREES
	if input == 1:
		ROTATION_DEGREES = 90
	elif input == -1:
		ROTATION_DEGREES = -90
	elif input == 0:
		ROTATION_DEGREES = 0
	cam_rotation.y += ROTATION_DEGREES
	#if cam_rotation.y > 270:
	#	cam_rotation.y = 0
	#	$Camera3D.rotation_degrees.y = -90
	#if cam_rotation.y < 0:
	#	$Camera3D.rotation_degrees.y = 360
	#	cam_rotation.y = 270
	#cam_rotation.z = hmls.rng(-2,6)

func _ready():
	if hmls.OS_CHECK == "mobile":
		hmls.ENABLE_SHADERS = false
	#hmls.PAUSE = false
	rotate_view(0)
	hmls.update_tiles("3d")
	# after updating the level tiles, set the cube position
	var CUBE = get_node("Cube")
	CUBE.position = Vector3(hmls.START_POSITION.x,0,hmls.START_POSITION.y)
	hmls.update_cube_position(Vector2(CUBE.position.x, CUBE.position.z))

var COLOR_CYCLE = 0
func _process(delta):
	if Input.is_action_just_pressed("ui_undo"):
		if hmls.ENABLE_SHADERS:
			hmls.ENABLE_SHADERS = false
		else:
			hmls.ENABLE_SHADERS = true
	if hmls.ENABLE_SHADERS:
		if not $Camera3D/shader_mobius.is_visible():
			$Camera3D/shader_mobius.show()
			$Camera3D/DirectionalLight3D.light_energy = 1.0
	else:
		if $Camera3D/shader_mobius.is_visible():
			$Camera3D/shader_mobius.hide()
			$Camera3D/DirectionalLight3D.light_energy = 0.75
	if Input.is_action_just_pressed("CAM_ROTATE_LEFT"):
		rotate_view(-1)
	if Input.is_action_just_pressed("CAM_ROTATE_RIGHT"):
		rotate_view(1)
	match hmls.ROTATION_COUNT:
		1:
			cam_offset = Vector3(3, 8, 5)
		2:
			cam_offset = Vector3(5, 8, -3)
		3:
			cam_offset = Vector3(-3, 8, -5)
		4:
			cam_offset = Vector3(-5, 8, 3)
		_:
			hmls.ROTATION_COUNT = 1
	if hmls.CLOSE_UP_CAM == "false":
		cam_offset = cam_offset * 2
	$Camera3D.position = lerp($Camera3D.position, $Cube.position + cam_offset, cam_speed * delta)
	$Camera3D.rotation_degrees = lerp($Camera3D.rotation_degrees, cam_rotation, (cam_speed + 1) * delta)
	if hmls.OS_CHECK == "desktop":
		if not $OmniLight3D.is_visible:
			$OmniLight3D.show()
		$OmniLight3D.position = lerp($OmniLight3D.position, $Cube.position + Vector3(0,2,0), (cam_speed + 6) * delta)
		$OmniLight3D.omni_range = 8
		$OmniLight3D.light_energy = 2
		$OmniLight3D.light_size = 0.5
		COLOR_CYCLE += 0.001
		if COLOR_CYCLE > 1.0:
			COLOR_CYCLE = 0
		$OmniLight3D.light_color = Color.from_hsv(COLOR_CYCLE,0.8,1.0,1.0)
	else:
		hmls.ENABLE_SHADERS = false
		if $OmniLight3D.is_visible():
			$OmniLight3D.hide()
	if Input.is_action_just_pressed("cam_swap"):
		if hmls.CLOSE_UP_CAM == "true":
			hmls.CLOSE_UP_CAM = "false"
		else:
			hmls.CLOSE_UP_CAM = "true"
