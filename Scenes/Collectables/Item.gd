class_name Item
extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func on_item_collected() -> void:
	pass
	
func on_item_collected_visual_queue() -> void:
	$Visuals/Sparkles.emitting = true
	
	$Area2D/CollisionShape2D.disabled = true
	var t = get_tree().create_tween()
	t.tween_property($Visuals/Sprite2D, "modulate", Color.TRANSPARENT, 0.2)
	t.tween_interval(0.8)
	t.tween_callback(queue_free)
