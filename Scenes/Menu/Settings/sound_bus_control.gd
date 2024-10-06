class_name SoundBusControl
extends HSlider

# The name of the audio bus this slider will control.
@export var bus_name: String

const _min_db = -60

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.max_value = -_min_db
	# Connect the value_changed signal to a custom method.
	connect("value_changed", _on_value_changed)
	# Initialize the slider value to the current volume of the bus.
	value = AudioServer.get_bus_volume_db(AudioServer.get_bus_index(bus_name)) - _min_db

# Called when the slider value changes.
func _on_value_changed(new_value: float) -> void:
	# Set the volume of the audio bus to the slider value.
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(bus_name), new_value + _min_db)
