class_name FxButton
extends Button

signal pressed_fx

var hover_sound: AudioStreamPlayer
var click_sound: AudioStreamPlayer
var can_propagate: bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hover_sound = AudioStreamPlayer.new()
	click_sound = AudioStreamPlayer.new()
	
	hover_sound.bus = "UI"
	click_sound.bus = "UI"
	hover_sound.stream = preload("res://Audio/Effects/hover_over_button.wav")
	click_sound.stream = preload("res://Audio/Effects/click_button.wav")
	
	add_child(hover_sound)
	add_child(click_sound)
	
	mouse_entered.connect(hover_sound.play)
	pressed.connect(_press_with_fx)
	click_sound.connect("finished", _on_fx_finished)

func _press_with_fx() -> void:
	if can_propagate:
		can_propagate = false
		click_sound.play()
	
func _on_fx_finished() -> void:
	can_propagate = true
	pressed_fx.emit()
