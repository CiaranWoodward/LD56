class_name Cassette
extends Item

@export var cassette_name: String

var _radio: GlobalRadio

func get_type() -> String:
	return "cassette"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	_radio = get_tree().root.get_node("Radio")
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super._process(delta)
	
func has_been_collected() -> bool:
	return _inventory.collected_items.any(func(item): return item == cassette_name)

func on_item_collected() -> void:
	super.on_item_collected()
	super.on_item_collected_visual_queue()
	_radio.play_cassette(cassette_name)
