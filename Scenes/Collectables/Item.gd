class_name Item
extends Node2D

var _menu: Menu

var _inventory: Inventory

func get_type() -> String:
	return ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_menu = get_tree().root.get_node("Menu")
	_inventory = get_tree().root.get_node("Menu").find_child("Inventory")
	if has_been_collected():
		queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is not Player:
		return
	on_item_collected()

func on_item_collected() -> void:
	_menu.add_item(self)
	
func has_been_collected() -> bool:
	return false
	
func on_item_collected_visual_queue() -> void:
	$Visuals/Sparkles.emitting = true
	
	$Area2D/CollisionShape2D.disabled = true
	var t = get_tree().create_tween()
	t.tween_property($Visuals/Sprite2D, "modulate", Color.TRANSPARENT, 0.2)
	t.tween_interval(0.8)
	t.tween_callback(queue_free)
