extends CharacterBody2D


var speed
const JUMP_VELOCITY = -400.0
var facing_left
var direction_left : bool
const projectile_Path = preload("res://Scenes/Spit_Projectile.tscn")

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@export var health: int
var myMarker : Marker2D

#var projectile_Path = preload("res://Scenes/projectile.tscn")
var spitVec
var shootTimer : Timer
@onready var player_in = false
@onready var state_machine = $AnimationTree.get("parameters/playback")
@onready var spit_done = true
@onready var player := get_tree().current_scene.get_node("Player")
@onready var fireSoundDone = true
#@onready var asp = $AudioStreamPlayer2D

func _ready():
	speed = 0
	myMarker = $CollisionShape2D/Marker2D
	direction_left = true
	shootTimer = $Timer
	
	#player_in = true
	add_to_group("Enemy")


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
		
	velocity.x = speed
	
	if player_in == false:
		state_machine.travel("WALK")
		if speed == 0:
			speed = -30
		if !$RayCast2D.is_colliding() && is_on_floor():
			flip()
	if player_in == true:
		speed = 0
		if spit_done:
			state_machine.travel("IDLE")
		if player and (player.global_position-$CollisionShape2D/Marker2D.global_position).x <= 0:
			if direction_left == false:
				if shootTimer.is_stopped():
					spit()
			else:
				flip()
				if shootTimer.is_stopped():
					spit()
		else:
			if direction_left == true:
				if shootTimer.is_stopped():	
					spit()
			else:
				flip()
				if shootTimer.is_stopped():
					spit()
		
func _process(delta):
	
	if health <= 0:
		die()
	
	#print(player_in)
	move_and_slide()
	
func flip():
	facing_left = !facing_left
	
	scale.x = abs(scale.x) * -1
	if facing_left:
		speed = abs(speed)
		direction_left = true
	else:
		speed = abs(speed) * -1
		direction_left = false
		
func spit():
	state_machine.travel("SPIT")
	var projectile = projectile_Path.instantiate()
	var spitVec = player.global_position-$CollisionShape2D/Marker2D.global_position
	projectile.direction(spitVec)
	get_parent().add_child(projectile)
	projectile.position = myMarker.global_position
	state_machine.travel
	shootTimer.start()
	
func take_damage(dmg:int):
	health -= dmg
	print(health)
	
func die():
	speed = 0
	state_machine.travel("DIE")
	if fireSoundDone:	
		$AudioStreamPlayer2D.play()
		fireSoundDone = false


func _on_agro_radius_body_entered(body):
	#print("entered agro")
	player_in = true
	#spit()
	
func _on_agro_radius_body_exited(body):
	player_in = false

func _on_animation_tree_animation_finished(anim_name):
	if anim_name == "DIE":
		queue_free()
	if anim_name == "SPIT":
		spit_done = true
		

func _on_animation_tree_animation_started(anim_name):
	if anim_name == "SPIT":
		spit_done = false
		



func _on_audio_stream_player_2d_finished():
	fireSoundDone = true
