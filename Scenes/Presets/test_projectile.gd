extends Area2D

@export var speed: float

@onready var sprite := $Sprite as Sprite2D

#func _draw():
	#draw_line(Vector2.ZERO, to_local(position + (sprite.texture.get_height()) * transform.x), Color.AQUA, 1)

func _process(delta):
	position += speed * delta * transform.x
