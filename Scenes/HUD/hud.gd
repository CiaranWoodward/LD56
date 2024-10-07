class_name Hud
extends Control

@export var speed: RichTextLabel
@export var target: RichTextLabel
@export var level_name: RichTextLabel
@export var score: RichTextLabel
@export var multiplier: RichTextLabel
@export var canvas: CanvasLayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	should_display(false)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func should_display(value: bool) -> void:
	if value:
		canvas.show()
	else: 
		canvas.hide()
	
func _set_speed(value: String) -> void:
	speed.text = "{0}mph".format([value])
	
func _set_target(value: int) -> void:
	target.text = "Quarterpipe speed to win: {0}mph".format([String.num(value)])
	
func _set_level_name(value: Node) -> void:
	level_name.text = value.name.capitalize()
	
func _set_score(value) -> void:
	score.text = "Score: {0}".format([value])
	
func _set_multiplier(value) -> void: 
	multiplier.text = "x{0}".format([value])
