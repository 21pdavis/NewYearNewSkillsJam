extends CharacterBody2D

@onready var state_machine = $AnimationTree.get("parameters/playback")

func _ready():
	state_machine.travel("idle")
