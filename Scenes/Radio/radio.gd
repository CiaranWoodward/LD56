class_name GlobalRadio
extends Node

var _tracks: Dictionary

var _cassettes: Dictionary

var _music_player: AudioStreamPlayer

var _is_playing_cassette

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_is_playing_cassette = false
	_tracks = {
		"rock": load("res://Audio/Music/bacground-rock.ogg"),
		"lofi": load("res://Audio/Music/low-fi-rock.ogg"),
		"ambient": load("res://Audio/Music/ambient.ogg"),
		"sad": load("res://Audio/Music/last-of-us.ogg")
	}
	
	_cassettes = {
		"advert": load("res://Audio/Cassettes/skateboard advert.ogg"),
		"lore 1": load("res://Audio/Cassettes/hawk explanation.ogg"),
		"lore 2": load("res://Audio/Cassettes/hawk uplifting.ogg"),
		"news 1": load("res://Audio/Cassettes/news broadcast 1.ogg"),
		"news 2": load("res://Audio/Cassettes/news broadcast 2.ogg"),
		"news 3": load("res://Audio/Cassettes/news broadcast 3.ogg")
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
	if is_playing_cassette():
		return
	
	assert(track in _tracks)
	if _music_player.stream == _tracks[track]:
		return
	_music_player.stop()
	_music_player.stream = _tracks[track]
	_music_player.play(0)
	
func is_playing_cassette():
	return _is_playing_cassette
	
	
func play_cassette(track: String) -> void:
	assert(track in _cassettes)
	_is_playing_cassette = true
	_music_player.finished.disconnect(_loop)
	var position = _music_player.get_playback_position()
	_music_player.stop()
	var old_bus = _music_player.bus
	_music_player.bus = "Voice"
	var old_stream = _music_player.stream
	_music_player.stream = _cassettes[track]
	_music_player.finished.connect(func(): 
		_music_player.stop()
		_music_player.bus = old_bus
		_music_player.stream = old_stream
		_music_player.play(position)
		_is_playing_cassette = false
		_music_player.finished.connect(_loop)
	, CONNECT_ONE_SHOT)
	_music_player.play(0)
	
	
