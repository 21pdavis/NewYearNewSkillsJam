extends Node2D

var vine_segment := preload("res://Scenes/Presets/vine_segment.tscn")

@onready var anchor: StaticBody2D = $Anchor
var segments: Array[RigidBody2D] = []
var joints: Array[PinJoint2D] = []

func _process(_delta):
	queue_redraw()

func draw_vine(attach_point: Node2D, vine_num: int):
	var spawn_direction := (attach_point.global_position - global_position).normalized()
	
	# create and position vines
	# TODO: off by a pixel here, should add 1 in some places
	for i in range(vine_num):
		# instantiate new vine segment
		var current_segment := vine_segment.instantiate() as RigidBody2D
		current_segment.name = "Segment{}".format([i + 1], "{}")
		add_child(current_segment)
		segments.append(current_segment)
		
		# position and rotate segment
		# TODO: rotation
		var segment_sprite := current_segment.get_node("Sprite") as Sprite2D
		var sprite_height := segment_sprite.texture.get_height()
		# 1/2 --> 3/2 --> etc. (pivot at center of segment)
		current_segment.position = (i + 0.5) * sprite_height * spawn_direction
		current_segment.look_at(attach_point.global_position)
		current_segment.rotate(PI / 2)
	
	# create and position joints, connect segments
	var segment_height = (segments[0].get_node("Sprite") as Sprite2D).texture.get_height()
	for i in range(vine_num + 1):
		var current_joint := PinJoint2D.new()
		current_joint.name = "Joint{}".format([i + 1], "{}")
		add_child(current_joint)
		joints.append(current_joint)
		
		current_joint.position = i * segment_height * spawn_direction
		
		# anchor to first segment connection
		if i == 0:
			current_joint.node_a = anchor.get_path()
			current_joint.node_b = segments[0].get_path()
		# last segment to attach_point connection
		elif i == vine_num:
			var held_body := attach_point.get_parent() as RigidBody2D
			
			current_joint.node_a = segments[-1].get_path()
			
			# shift body up to end of vine connection
			var body_sprite := held_body.get_node("Sprite") as Sprite2D
			held_body.global_position = current_joint.global_position + (body_sprite.texture.get_height() / 2) * spawn_direction
			
			current_joint.node_b = held_body.get_path()
		# segment-to-segment connections
		else:
			current_joint.node_a = segments[i].get_path()
			current_joint.node_b = segments[i - 1].get_path()

func sever_segment(idx: int):
	joints[idx].queue_free()
	joints.remove_at(idx)
