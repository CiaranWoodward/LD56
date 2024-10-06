extends VBoxContainer

var _add_mult: FxButton
var _reset_mult: FxButton
var _add_score: FxButton
var _next_level: FxButton
var _add_item: FxButton

var _menu: Menu

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_menu = get_tree().root.get_node("Menu")
	_add_mult = $DebugAddMult
	_reset_mult = $DebugResetMult
	_add_score = $DebugAddScore
	_next_level = $DebugNextLevel
	_add_item = $DebugAddItem
	
	_add_mult.pressed_fx.connect(_menu.increase_multiplier)
	_reset_mult.pressed_fx.connect(_menu.reset_multiplier)
	_add_score.pressed_fx.connect(_func_add_score)
	_next_level.pressed_fx.connect(_menu.complete_level)
	_add_item.pressed_fx.connect(_menu.add_item)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _func_add_score():
	_menu.add_score(10)
