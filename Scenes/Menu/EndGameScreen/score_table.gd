extends HSplitContainer

var _player: Dictionary = {
	"name": "Tiny Hawk",
	"score": 0
}

var _scoreboard: Array[Dictionary] = [
	{
		"name": "Bam Magpie-gera",
		"score": 6340
	},
	{
		"name": "Mike McGull",
		"score": 4566
	},
	{
		"name": "Duckbill Danforth",
		"score": 3211
	},
	{
		"name": "Steve Owla",
		"score": 1255
	},
	{
		"name": "Random Pengin",
		"score": 232
	}
]

var _menu: Menu

var _name_col: Node

var _score_col: Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_name_col = $Name
	_score_col = $Score
	_menu = get_tree().root.get_node("Menu")
	_build_table()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if _player.score != _menu._total_score:
		_build_table()
		
func _build_table():
	_player.score = _menu._total_score
	var _scoreboard_copy: Array[Dictionary] = []
	_scoreboard_copy.append_array(_scoreboard)
	_scoreboard_copy.append(_player)
	# sort data
	_scoreboard_copy.sort_custom(_sort_scoreboard)
	# clear old table
	_name_col.get_children().all(func(child: Node): 
		_name_col.remove_child(child)
		child.free()
		return true
	)
	_score_col.get_children().all(func(child: Node):
		_score_col.remove_child(child)
		child.free()
		return true
	)
	_scoreboard_copy.all(func(obj: Dictionary):
		var _name = RichTextLabel.new()
		_name.text = obj.name
		_name.autowrap_mode = TextServer.AUTOWRAP_OFF
		_name.clip_contents = false
		_name.fit_content = true
		_name.anchor_left = true
		_name.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		_name_col.add_child(_name)
		var _score = RichTextLabel.new()
		_score.text = String.num(obj.score)
		_score.autowrap_mode = TextServer.AUTOWRAP_OFF
		_score.clip_contents = false
		_score.fit_content = true
		_score.anchor_right = true
		_score.size_flags_horizontal = Control.SIZE_SHRINK_END
		_score_col.add_child(_score)
		return true
	)
	_scoreboard_copy.clear()
		
func _sort_scoreboard(a: Dictionary, b: Dictionary):
	return a.score > b.score
	
