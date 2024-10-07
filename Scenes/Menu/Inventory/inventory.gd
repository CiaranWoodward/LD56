class_name Inventory
extends Control

@export var _hats: OptionButton

@export var _cassettes: HFlowContainer

var hats = [
	"none",
	"beanie",
	"cap",
	"headphones",
	"fedora",
	"headset"
]

var hat = "none"

var _radio: GlobalRadio

var collected_items: Array[String] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_radio = get_tree().root.get_node("Radio")
	hats.all(func(hat):
		_hats.add_item(hat)
		_hats.set_item_disabled(_hats.item_count - 1, true)
		return true
	)
	_hats.set_item_disabled(0, false)
	_hats.select(0)
	_hats.item_selected.connect(func(value): hat = hats[value])

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if _radio.is_playing_cassette():
		_cassettes.get_children().all(func(child: Button): 
			child.disabled = true
			return true
		)
	else:
		_cassettes.get_children().all(func(child: Button): 
			child.disabled = false
			return true
		)
	
func _add_hat(picked_up: HatPickup):
	var index = 0
	for i in range(hats.size()):
		if hats[i] == picked_up.hat_name:
			index = i
			break
	
	_hats.set_item_disabled(index, false)
	_hats.select(index)
	hat = picked_up.hat_name
	collected_items.append(picked_up.hat_name)
	
func _add_cassette(cassette: Cassette):
	var button = Button.new()
	button.text = cassette.cassette_name.capitalize()
	var cassette_name = cassette.cassette_name
	button.pressed.connect(func(): _radio.play_cassette(cassette_name))
	_cassettes.add_child(button)
	collected_items.append(cassette_name)
