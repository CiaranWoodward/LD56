class_name SoundBusMute
extends CheckButton

# The name of the audio bus this slider will control.
@export var bus_name: String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_pressed_no_signal(!AudioServer.is_bus_mute(AudioServer.get_bus_index(bus_name)))
	toggled.connect(_on_value_changed)

# Called when the slider value changes.
func _on_value_changed(new_value: bool) -> void:
	# Set the volume of the audio bus to the slider value.
	AudioServer.set_bus_mute(AudioServer.get_bus_index(bus_name), !new_value)
