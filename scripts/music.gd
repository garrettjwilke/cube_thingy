extends Node

@onready var player = $AudioStreamPlayer2D

var song
var change_song = false
func music_looper():
	if GLOBALS.MUTE_MUSIC:
		if player.playing:
			player.stop()
		return
	if player.playing:
		return
	if change_song == true:
		change_song = false
		var song_string = str("res://assets/music/loop_",CURRENT_LEVEL,".mp3")
		if not ResourceLoader.exists(song_string):
			$ColorRect.show()
			song = load("res://assets/music/loop_1.mp3")
		else:
			$ColorRect.hide()
			song = load(song_string)
	player.stream = song
	#player.volume_db = -2
	player.play()

func _ready():
	change_song = true

@onready var CURRENT_LEVEL = GLOBALS.LEVEL
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if CURRENT_LEVEL != GLOBALS.LEVEL:
		CURRENT_LEVEL = GLOBALS.LEVEL
		player.stop()
		change_song = true
	music_looper()
