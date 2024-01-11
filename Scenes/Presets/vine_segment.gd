extends RigidBody2D

func _ready():
	add_to_group("vine_segment")

func _on_area_2d_area_entered(area: Area2D):
	if "vine_slicer" in area.get_groups():
		var vine = get_parent()
		var segment_index = vine.segments.find(self)
		vine.sever_segment(segment_index)
