extends Area2D

#var Main_instance = Main_tscn.instantiate()
#add_child(Main_instance)
#@onready var Main_instance = get_tree().current_scene
#@onready var playerSprite = Main_instance.get_node("Player/CollisionShape2D2")
#@onready var enemySprite = Main_instance.get_node("Enemy/CollisionShape2D")
#var projectile_velocity = enemySprite.global_position-playerSprite.Marker2D.global_position
@onready var speed = 200
var projectile_velocity

func direction(direct:Vector2):
	projectile_velocity = direct

func _physics_process(delta):
	position += (projectile_velocity.normalized() * delta * speed)
	
func destroy():
	queue_free()


func _on_area_entered(area):
	#print(area.name)
	destroy()


func _on_body_entered(body: PhysicsBody2D):
	#print(body.name)
	if "Player" in body.get_groups():
		body.take_damage(1)
	destroy()


func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
