extends Node

@onready var player = $AudioStreamPlayer2D

func music_looper():
	if GLOBALS.MUTE_MUSIC:
		return
	if player.playing == true:
		return
	player.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	music_looper()
