extends Area2D

@export var speed: float

@onready var sprite := $Sprite as Sprite2D

func _ready():
	add_to_group("vine_slicer")

func _process(delta):
	position += speed * delta * transform.x
