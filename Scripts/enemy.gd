extends CharacterBody2D


var speed = -30.0
const JUMP_VELOCITY = -400.0
var facing_left
var direction_left : bool
const projectile_Path = preload("res://Scenes/Spit_Projectile.tscn")

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var health
var myMarker : Marker2D

#var projectile_Path = preload("res://Scenes/projectile.tscn")
var Main
var spitVec
var playerColl
var shootTimer : Timer

func _ready():
	health = 100
	myMarker = $CollisionShape2D/Marker2D
	direction_left = true
	shootTimer = $Timer
	add_to_group("Enemy")



func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
		
	velocity.x = speed
	
	#print($RayCast2D.is_colliding())
	
	if !$RayCast2D.is_colliding() && is_on_floor():
		flip()

	# Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	#var direction = Input.get_axis("ui_left", "ui_right")
	#if direction:
		#velocity.x = direction * SPEED
	#else:
		#velocity.x = move_toward(velocity.x, 0, SPEED)
	
	if health <= 0:
		die()
	

	move_and_slide()
	
	if Input.is_action_pressed("ui_select") and shootTimer.is_stopped():
		spit()
	
func flip():
	facing_left = !facing_left
	
	scale.x = abs(scale.x) * -1
	if facing_left:
		speed = abs(speed)
		direction_left = true
	else:
		speed = abs(speed) * -1
		direction_left = false
func agro():
	pass
		
func spit():
	var projectile = projectile_Path.instantiate()
	var Main = get_tree().current_scene
	var playerColl = Main.get_node("Player")
	var spitVec = playerColl.global_position-$CollisionShape2D/Marker2D.global_position
	projectile.direction(spitVec)
	get_parent().add_child(projectile)
	projectile.position = myMarker.global_position
	shootTimer.start()
	
func take_damage(dmg:int):
	health -= dmg
	print(health)
	
func die():
	queue_free()


func _on_agro_radius_body_entered(body):
	pass # Replace with function body.
