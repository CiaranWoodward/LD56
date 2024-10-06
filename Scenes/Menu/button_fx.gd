class_name FxButton
extends Button

signal pressed_fx

var _hover_sound: AudioStreamPlayer
var _click_sound: AudioStreamPlayer
var _can_propagate: bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_hover_sound = AudioStreamPlayer.new()
	_click_sound = AudioStreamPlayer.new()
	
	_hover_sound.bus = "UI"
	_click_sound.bus = "UI"
	_hover_sound.stream = preload("res://Audio/Effects/hover_over_button.wav")
	_click_sound.stream = preload("res://Audio/Effects/click_button.wav")
	
	add_child(_hover_sound)
	add_child(_click_sound)
	
	mouse_entered.connect(_hover_sound.play)
	pressed.connect(_press_with_fx)
	_click_sound.connect("finished", _on_fx_finished)

func _press_with_fx() -> void:
	if _can_propagate:
		_can_propagate = false
		_click_sound.play()
	
func _on_fx_finished() -> void:
	_can_propagate = true
	pressed_fx.emit()
