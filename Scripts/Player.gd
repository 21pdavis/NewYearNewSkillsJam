extends CharacterBody2D


const SPEED = 150.0
const JUMP_VELOCITY = -200.0
const bulletPath = preload("res://Scenes/Bullet.tscn")

var look_direction = 1
var state_machine
var prev_velocity
var myMarker : Marker2D
var myMarker2 : Marker2D
var shootTimer : Timer
var isShooting : bool
@onready var isDead = false
@onready var fullyDead = false
@onready var stepSoundDone = true
@onready var stepDone = true
@export var player_health: int

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var sprite : Sprite2D
func _ready():
	sprite = $PlayerRevision4
	state_machine = $AnimationTree.get("parameters/playback")
	myMarker = $CollisionShape2D2/Marker2D
	myMarker2 = $CollisionShape2D2/Marker2D2
	shootTimer = $Timer
	isShooting = false
	add_to_group("Player")
	

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
		if velocity.y<0:
			state_machine.travel("FALL")
			

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor() and isDead == false:
		velocity.y = JUMP_VELOCITY
		if velocity.y>0:
			state_machine.travel("JUMP")

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	if isDead == false:
		var direction = Input.get_axis("ui_left", "ui_right")
		if direction:
			if is_on_floor():
				state_machine.travel("WALK")
				if stepSoundDone and stepDone:
					$AudioStreamPlayer2D.play()
					stepSoundDone = false
				
			velocity.x = direction * SPEED
			if direction>0:
				look_direction = 1
			else:
				look_direction = 0
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			if is_on_floor():	
				if isShooting == true:
					state_machine.travel("SHOOT_IDLE")
				else:
					state_machine.travel("IDLE")
		
	if look_direction == 1:
		sprite.flip_h = false
	else:
		sprite.flip_h = true
		
	if Input.is_action_pressed("ui_select") and shootTimer.is_stopped() and isDead == false:
		shoot()
	else:
		isShooting = false
	if fullyDead:
		print("fulldead")
		Engine.time_scale = 0

	move_and_slide()
	
#func _process(delta):
	
func take_damage(dmg:int):
	print("OW")
	player_health -= dmg
	if player_health <= 0:
		die()

func die():
	isDead = true
	state_machine.travel("DIE")
	if fullyDead:
		state_machine.travel("End")

func shoot():
	var bullet = bulletPath.instantiate()
	bullet.direction(not sprite.flip_h)
	get_parent().add_child(bullet)
	isShooting = true
	if sprite.flip_h == false:
		bullet.position = myMarker.global_position
	else:
		bullet.position = myMarker2.global_position
	shootTimer.start()

func _on_animation_tree_animation_finished(anim_name):
	if anim_name == "DIE":
		fullyDead = true
	if anim_name == "WALK":
		stepDone = true
		
func _on_audio_stream_player_2d_finished():
	stepSoundDone = true




func _on_animation_player_animation_started(anim_name):
	if anim_name == "WALK":
		stepDone = false


func _on_animation_tree_animation_started(anim_name):
	if anim_name == "WALK":
		stepDone = false
