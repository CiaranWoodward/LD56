class_name Inventory
extends Control

@export var _hats: OptionButton

@export var _cassettes: HFlowContainer

var _radio: GlobalRadio

func get_type():
	pass

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_radio = get_tree().root.get_node("Radio")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if _radio.is_playing_cassette():
		_cassettes.get_children().all(func(child: Button): 
			child.disabled = true
		)
	else:
		_cassettes.get_children().all(func(child: Button): 
			child.disabled = false
		)
	
func _add_hat(hat: Item):
	pass
	
func _add_cassette(cassette: Cassette):
	var button = Button.new()
	button.text = cassette.cassette_name.capitalize()
	var cassette_name = cassette.cassette_name
	button.pressed.connect(func(): _radio.play_cassette(cassette_name))
	_cassettes.add_child(button)
