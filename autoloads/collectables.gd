extends Node

@export var test : float
@export var collectableItems = {"blue hat" : true}
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_resetDefaults()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	for key in collectableItems:
		print(str(key) + " " + str(collectableItems[key]))
	pass


func _resetDefaults() -> void:
	for key in collectableItems:
		collectableItems[key] = false
