extends Item

@export var audio_file : AudioStreamWAV

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is not Player:
		return
	on_item_collected()

func on_item_collected() -> void:
	on_item_collected_visual_queue()
	
	var menu : Menu = get_tree().root.get_node("Menu")
	menu.add_item()
