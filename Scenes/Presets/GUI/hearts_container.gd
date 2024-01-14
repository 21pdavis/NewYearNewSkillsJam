extends HBoxContainer

func update_hearts(current_health: int):
	var hearts := get_children()
	
	for i in range(hearts.size()):
		# TODO: check
		hearts[i].update((i + 1) <= current_health)
