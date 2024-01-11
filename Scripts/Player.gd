extends CharacterBody2D


const SPEED = 150.0
const JUMP_VELOCITY = -200.0
const bulletPath = preload("res://Scenes/Bullet.tscn")

var look_direction = 1
var state_machine
var prev_velocity
var myMarker : Marker2D
var myMarker2 : Marker2D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var sprite : Sprite2D
func _ready():
	sprite = $PlayerRevision4
	state_machine = $AnimationTree.get("parameters/playback")
	myMarker = $CollisionShape2D2/Marker2D
	myMarker2 = $CollisionShape2D2/Marker2D2
	

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
		if velocity.y<0:
			state_machine.travel("FALL")
			

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		if velocity.y>0:
			state_machine.travel("JUMP")

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		if is_on_floor():
			state_machine.travel("WALK")
		velocity.x = direction * SPEED
		if direction>0:
			look_direction = 1
		else:
			look_direction = 0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if is_on_floor():	
			state_machine.travel("IDLE")
		
	if look_direction == 1:
		sprite.flip_h = false
	else:
		sprite.flip_h = true
		
	if Input.is_action_just_pressed("ui_select"):
		shoot()

	move_and_slide()


func shoot():
	var bullet = bulletPath.instantiate()
	bullet.direction(not sprite.flip_h)
	get_parent().add_child(bullet)
	if sprite.flip_h == false:
		bullet.position = myMarker.global_position
	else:
		bullet.position = myMarker2.global_position
