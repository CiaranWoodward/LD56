class_name GlobalRadio
extends Node

var _tracks: Dictionary

var _cassettes: Dictionary

var _music_player: AudioStreamPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_tracks = {
		"rock": load("res://Audio/Music/bacground-rock.ogg"),
		"lofi": load("res://Audio/Music/low-fi-rock.ogg"),
		"ambient": load("res://Audio/Music/ambient.ogg"),
		"sad": load("res://Audio/Music/last-of-us.ogg")
	}
	
	_cassettes = {
		"advert": load("res://Audio/Cassettes/skateboard advert.wav"),
		"lore": load("res://Audio/Cassettes/hawk explanation.wav"),
		"news": load("res://Audio/Cassettes/news broadcast.wav"),
		"intro": load("res://Audio/Cassettes/intro whole thing.wav")
	}
	
	_music_player = $GlobalMusic
	_music_player.stream = _tracks.rock
	_music_player.play(0)
	# loop music
	_music_player.finished.connect(_loop)

func _loop():
	_music_player.play(0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func play_music(track: String) -> void:
	assert(track in _tracks)
	_music_player.stop()
	_music_player.stream = _tracks[track]
	_music_player.play(0)
	
func play_cassette(track: String) -> void:
	assert(track in _cassettes)
	_music_player.finished.disconnect(_loop)
	var position = _music_player.get_playback_position()
	_music_player.stop()
	var old_stream = _music_player.stream
	_music_player.stream = _cassettes[track]
	_music_player.finished.connect(func(): 
		_music_player.stop()
		_music_player.stream = old_stream
		_music_player.play(position)
	)
	_music_player.play(0)
	
	
