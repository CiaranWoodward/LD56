extends FxButton

var _menu: Menu

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	_menu = $"/root/Menu"
	pressed_fx.connect(_on_restart)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	visible = _menu.is_in_game()
	
func _on_restart():
	_menu.restart_level()
