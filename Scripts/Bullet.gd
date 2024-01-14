extends Area2D


var bullet_velocity = Vector2(1,0)
var speed

func direction(direct:bool):
	if direct == true:
		speed = 500
	if direct == false:
		speed = -500

func _physics_process(delta):
	position += (bullet_velocity.normalized() * delta * speed)
	
	
func destroy():
	queue_free()
	print("Bye")




func _on_area_entered(area):
	if "Player" in area.get_groups():
		destroy()


func _on_body_entered(body):
	if "Enemy" in body.get_groups():
		body.take_damage(20)
	destroy()


func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()


func _on_area_exited(area):
	print(area.name)
	if "Player" not in area.get_groups():
		destroy()
