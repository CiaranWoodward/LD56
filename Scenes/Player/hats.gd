class_name Hats
extends AnimatedSprite2D

var _inventory: Inventory

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if get_parent().name != "Visuals":
		_inventory = $/root/Menu/Canvas/Panel/MenuContainer/Inventory

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_instance_valid(_inventory):
		set_variant(_inventory.hat)
			
func set_variant(variant):
	match variant:
		"none":
			visible = false
		"beanie":
			frame = 1
			visible = true
			self_modulate = Color.ROYAL_BLUE
		"cap":
			frame = 3
			visible = true
			self_modulate = Color.SEA_GREEN
		"headphones":
			frame = 0
			visible = true
			self_modulate = Color.DARK_RED
		"fedora":
			frame = 2
			visible = true
			self_modulate = Color.SLATE_GRAY
		"headset":
			frame = 4
			visible = true
			self_modulate = Color.WHITE
