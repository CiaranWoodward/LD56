class_name HatPickup
extends Item

@export var hat_name: String

func get_type() -> String:
	return "hat"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	var art: Hats = $"Visuals/Sprite2D"
	art.set_variant(hat_name)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super._process(delta)
	
func has_been_collected() -> bool:
	return _inventory.collected_items.any(func(item): return item == hat_name)

func on_item_collected() -> void:
	super.on_item_collected()
	super.on_item_collected_visual_queue()
