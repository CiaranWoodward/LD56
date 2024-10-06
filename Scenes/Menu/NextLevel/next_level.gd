class_name NextLevel
extends Control

@export var level_score: RichTextLabel
@export var total_score: RichTextLabel
@export var items_found: RichTextLabel

var _menu: Menu

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_menu = get_tree().root.get_node("Menu")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	level_score.text = String.num(_menu._level_score)
	total_score.text = String.num(_menu._total_score)
	items_found.text = String.num(_menu._level_item_count)
	
