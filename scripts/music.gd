extends Node

@onready var player = $AudioStreamPlayer2D

var song
var song_number = 0
func load_song():
	song_number += 1
	#song_number = 2
	var song_string = str("res://assets/music/loop_",song_number,".mp3")
	if not FileAccess.file_exists(song_string):
		song_number = 0
		load_song()
		return
	else:
		song = load(song_string)

func music_looper():
	if GLOBALS.MUTE_MUSIC:
		if player.playing:
			player.stop()
		return
	if player.playing:
		return
	player.stream = song
	player.volume_db = -2
	player.play()

func _ready():
	load_song()

var TIMER = 0
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	TIMER += delta
	if TIMER > 90:
		load_song()
		TIMER = 0
	music_looper()
