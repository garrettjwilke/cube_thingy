extends Node

@onready var player = $AudioStreamPlayer2D

func music_looper():
	if player.playing == true:
		return
	player.play()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	music_looper()
