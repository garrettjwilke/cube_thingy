extends Node2D

var hue = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	var color = Color.from_hsv(1.0/6.0, 1.0, 1.0) # Equivalent to "hsv(60, 100%, 100%)"
	print(color) # Prints "1,1,0,1" which is opaque yellow
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if hue >1:
		hue = 0
	hue += 0.0005
	$MarginContainer/ColorRect.color = Color.from_hsv(hue, 0.33, 0.89)
	pass
