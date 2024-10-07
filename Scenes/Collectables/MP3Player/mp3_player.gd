extends Item

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super._ready()
	
func on_item_collected() -> void:
	super.on_item_collected()
	on_item_collected_visual_queue()
