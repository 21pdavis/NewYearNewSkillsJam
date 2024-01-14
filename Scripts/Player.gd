extends CharacterBody2D

signal health_changed

@export var SPEED: float
@export var JUMP_VELOCITY: float
const bulletPath = preload("res://Scenes/Bullet.tscn")

@export var swing_strength: float
@onready var climb_area := $ClimbArea as Area2D

var look_direction = 1
var state_machine
var prev_velocity
var myMarker : Marker2D
var myMarker2 : Marker2D
var shootTimer : Timer
var isShooting : bool
@onready var isDead = false
@onready var fullyDead = false
@export var player_health: int

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var sprite : Sprite2D
var climbing := false
var vine_being_climbed = null

func _ready():
	add_to_group("player")

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
	if Input.is_action_just_pressed("ui_accept") and (is_on_floor() or climbing) and not isDead:
		if climbing:
			climbing = false
			vine_being_climbed.currently_being_climbed = false
			vine_being_climbed = null
			global_rotation_degrees = 0
			reparent(get_tree().current_scene)

		velocity.y = JUMP_VELOCITY
		if velocity.y>0:
			state_machine.travel("JUMP")

	var vertical_direction = Input.get_axis("ui_down", "ui_up")
	var vine_bodies := climb_area.get_overlapping_bodies()
	vine_bodies.sort_custom(
		func sort_by_distance_to_player(pos1: Node2D, pos2: Node2D):
			if (pos1.global_position - global_position).length() < (pos2.global_position - global_position).length():
				return true
			return false
	)
	
	if vertical_direction and vine_bodies:
		var closest_vine_segment := vine_bodies[0] as RigidBody2D
		var vine := closest_vine_segment.get_parent()
		var segment_index := (vine.segments as Array[RigidBody2D]).find(closest_vine_segment)
		
		# stick player onto closest vine segment
		if vine.segments_connected_to_root[segment_index]:
			climbing = true
			vine_being_climbed = vine
			vine.currently_being_climbed = true
			reparent(closest_vine_segment)
			velocity = SPEED * delta * vertical_direction * vine.segment_ups[segment_index]
	elif not vertical_direction and climbing:
		velocity = Vector2.ZERO
	elif climbing and (is_on_floor() or not vine_bodies):
		climbing = false
		vine_being_climbed.currently_being_climbed = false
		vine_being_climbed = null
		global_rotation_degrees = 0
		reparent(get_tree().current_scene)
	
	if climbing:
		global_rotation_degrees = 0
		position.x = 0
		
	# Add the gravity.
	if not is_on_floor() and not climbing:
		velocity.y += gravity * delta

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	if not isDead:
		var horizontal_direction = Input.get_axis("ui_left", "ui_right")
		if horizontal_direction:
			if horizontal_direction > 0:
				look_direction = 1
			else:
				look_direction = 0
					
			if not climbing:
				velocity.x = horizontal_direction * SPEED * delta
				if is_on_floor():
					state_machine.travel("WALK")
			else:
				var vine_segment := get_parent() as RigidBody2D
				if vine_segment.get_parent().swingable:
					vine_segment.apply_impulse(swing_strength * horizontal_direction * delta * global_transform.x)
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
