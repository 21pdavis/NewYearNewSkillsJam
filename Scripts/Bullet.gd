extends CharacterBody2D


var bullet_velocity = Vector2(1,0)
var speed

func direction(direct:bool):
	if direct == true:
		speed = 500
	if direct == false:
		speed = -500

func _physics_process(delta):
	var collision_info = move_and_collide(bullet_velocity.normalized() * delta * speed)
