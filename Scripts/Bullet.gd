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
	#print("area")
	##print(area.name)
	#if "Enemy" in area.get_groups():
		#area.take_damage(20)
	destroy()


func _on_body_entered(body):
	#destroy()
	#print("body")
	#print(body.name)
	if "Enemy" in body.get_groups():
		body.take_damage(20)
	destroy()


func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
