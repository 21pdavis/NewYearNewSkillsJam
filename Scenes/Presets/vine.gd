extends Node2D

var vine_segment := preload("res://Scenes/Presets/vine_segment.tscn")
var segments: Array[RigidBody2D]
var joints: Array[PinJoint2D]

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func draw_vine(end):
	var start := position
	# TODO: add vines here
