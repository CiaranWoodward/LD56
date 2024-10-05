extends Sprite2D

@export var itemType := ""
@onready var aoe = $AreaOfEffect

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for child in $"Visual/HatBody".get_children():
		if(child.name == itemType):
			child.visible = true
		else:
			child.visible = false
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var overlaps = aoe.get_overlapping_bodies()
	for overlap in overlaps:
		if(overlap.name == "Player"):
			Collectables.collectableItems[itemType] = true
			$".".queue_free()
	pass
