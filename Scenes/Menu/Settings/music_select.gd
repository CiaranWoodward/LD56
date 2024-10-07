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
	item_selected.connect(func(value): _radio.play_music(_options[value]))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
