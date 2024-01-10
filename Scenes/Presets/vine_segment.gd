extends RigidBody2D

func _on_area_2d_area_entered(area):
	if "vine_slicer" in area.get_groups():
		pass
