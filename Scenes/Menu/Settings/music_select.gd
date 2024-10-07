extends OptionButton

const _options = [
	"rock",
	"lofi",
	"sad",
	"ambient"
]

var _radio: GlobalRadio

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_radio = $"/root/Radio"
	item_selected.connect(_command_select)
	
func _command_select(value: int):
	_radio.play_music(_options[value])
	
func set_selected(option: String):
	item_selected.disconnect(_command_select)
	for i in range(_options.size()):
		if _options[i] == option:
			selected = i
	item_selected.connect(_command_select)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
