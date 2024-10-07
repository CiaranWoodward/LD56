extends AnimationTree

func get_player() -> Player:
	return get_parent().get_parent().get_parent()
