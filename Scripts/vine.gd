extends Node2D

var vine_segment := preload("res://Scenes/Presets/vine_segment.tscn")

@onready var anchor: StaticBody2D = $Anchor
var segments: Array[RigidBody2D] = []
var joints: Array[PinJoint2D] = []
var segment_ups: Array[Vector2] = []
var segments_connected_to_root: Array[bool] = []
var severed_joint_indexes: Array[int] = []
var disabled_projectiles: Array[Area2D] = []

var currently_being_climbed: bool = false

func _ready():
	add_to_group("vine")

func _process(_delta):
	var i = 0
	for segment in segments:
		segment_ups[i] = -segment.transform.y
		i += 1
	
func generate_vine(vine_num: int, attached: bool, attach_point: Node2D):
	var spawn_direction := (attach_point.global_position - global_position).normalized()
	
	# create and position vines
	# TODO: off by a pixel here, should add 1 in some places
	for i in range(vine_num):
		# instantiate new vine segment
		var current_segment := vine_segment.instantiate() as RigidBody2D
		current_segment.name = "Segment{}".format([i + 1], "{}")
		add_child(current_segment)
		segments.append(current_segment)
		segment_ups.append(-current_segment.transform.y)
		segments_connected_to_root.append(true)
		
		# position and rotate segment
		var segment_sprite := current_segment.get_node("Sprite") as Sprite2D
		var sprite_height := segment_sprite.texture.get_height()
		
		# 1/2 --> 3/2 --> etc. (pivot at center of segment)
		current_segment.position = (i + 0.5) * sprite_height * spawn_direction
		current_segment.look_at(global_position)
		current_segment.rotate(PI / 2)
		
		if attach_point and attach_point.get_parent() is RigidBody2D:
			current_segment.add_collision_exception_with(attach_point.get_parent())
	
	# create and position joints, connect segments
	var segment_height = (segments[0].get_node("Sprite") as Sprite2D).texture.get_height()
	for i in range(vine_num + (1 if attach_point else 0)):
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
		elif i == vine_num and attached:
			var held_body := attach_point.get_parent() as RigidBody2D
			
			current_joint.node_a = segments[-1].get_path()
			
			# shift body up to end of vine connection
			var body_sprite := held_body.get_node("Sprite") as Sprite2D
			held_body.global_position = current_joint.global_position + (body_sprite.texture.get_height() / 2) * spawn_direction
			
			current_joint.node_b = held_body.get_path()
		# segment-to-segment connections
		elif i < vine_num:
			current_joint.node_a = segments[i].get_path()
			current_joint.node_b = segments[i - 1].get_path()

func sever_segment(idx: int):
	if idx not in severed_joint_indexes and not currently_being_climbed:
		joints[idx].queue_free()
		severed_joint_indexes.append(idx)
		for i in range(idx, segments.size()):
			segments_connected_to_root[i] = false
