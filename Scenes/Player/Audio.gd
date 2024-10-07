extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func play_rolling(pitch: float):
	$RollingAudio.pitch_scale = pitch * randf_range(0.95, 1.05)
	if $RollingAudio.stream_paused:
		$RollingAudio.stream_paused = false
	else:
		$RollingAudio.play($RollingAudio.get_playback_position())

func stop_rolling():
	$RollingAudio.stream_paused = true

func play_grinding():
	$GrindingAudio.pitch_scale = randf_range(0.9, 1.1)
	if $GrindingAudio.stream_paused:
		$GrindingAudio.stream_paused = false
	else:
		$GrindingAudio.play($GrindingAudio.get_playback_position())
	var gs = $GrindStart.get_children().pick_random()
	gs.pitch_scale = randf_range(0.9, 1.1)
	gs.play()

func stop_grinding():
	$GrindingAudio.stream_paused = true

func play_trick():
	var ts = $TrickSound.get_children().pick_random()
	ts.pitch_scale = randf_range(0.9, 1.1)
	ts.play()

func play_landing():
	var ls = $LandSound.get_children().pick_random()
	ls.pitch_scale = randf_range(0.9, 1.1)
	ls.play()
