extends Node2D

var vine_segment := preload("res://Scenes/Presets/vine_segment.tscn")

@onready var anchor: StaticBody2D = $Anchor
var segments: Array[RigidBody2D]
var joints: Array[PinJoint2D]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	queue_redraw()

# TODO: dynamic vine lengths (another parameter? Dynamic detection based on segment height?)
func draw_vine(attach_point: Node2D):
	var start := global_position
	# start and end are in global
	var spawn_direction := to_local((attach_point.global_position - start).normalized())
	# determine rough number of vines (can tweak this later, make it dynamic, etc.), for now just static
	var vine_num = 3
	
	# create and position vines
	# TODO: off by a pixel here, should add 1 in some places
	var segment_multiplier := 1.0/2
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
		current_segment.position = segment_multiplier * sprite_height * (start + spawn_direction)
		
		# 1/2 --> 3/2 --> etc. (pivot at center of segment)
		segment_multiplier += 1
	
	# create and position joints, connect segments
	# TODO: messy, should use a diff method
	var segment_height = (segments[0].get_node("Sprite") as Sprite2D).texture.get_height()
	var joint_multiplier = 0
	for i in range(vine_num + 1):
		var current_joint := PinJoint2D.new()
		current_joint.name = "Joint{}".format([i + 1], "{}")
		add_child(current_joint)
		joints.append(current_joint)
		
		current_joint.position = joint_multiplier * segment_height * (start + spawn_direction)
		
		# anchor to first segment connection
		if i == 0:
			current_joint.node_a = anchor.get_path()
			current_joint.node_b = segments[0].get_path()
		# last segment to attach_point connection
		elif i == vine_num:
			current_joint.node_a = segments[-1].get_path()
			current_joint.node_b = attach_point.get_parent().get_path()
		# segment-to-segment connections
		else:
			current_joint.node_a = segments[i].get_path()
			current_joint.node_b = segments[i - 1].get_path()
		
		joint_multiplier += 1
