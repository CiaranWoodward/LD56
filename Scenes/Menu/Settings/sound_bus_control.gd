class_name SoundBusControl
extends HSlider

# The name of the audio bus this slider will control.
@export var bus_name: String

const min_db = -60
const scale_factor = 0.5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.max_value = -min_db * scale_factor
	# Connect the value_changed signal to a custom method.
	connect("value_changed", _on_value_changed)
	# Initialize the slider value to the current volume of the bus.
	value = AudioServer.get_bus_volume_db(AudioServer.get_bus_index(bus_name)) - min_db * scale_factor

# Called when the slider value changes.
func _on_value_changed(new_value: float) -> void:
	# Set the volume of the audio bus to the slider value.
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(bus_name), new_value + min_db * scale_factor)
