extends CharacterBody2D


const SPEED = 6000
const JUMP_VELOCITY = -400.0

@export var swing_strength: float

var projectile := preload("res://Scenes/Presets/test_projectile.tscn")
@onready var sprite := $Sprite as Sprite2D
@onready var climb_area := $ClimbArea as Area2D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var climbing := false
var vine_being_climbed = null

func _ready():
	add_to_group("player")

func _process(delta):
	if Input.is_action_just_pressed("fire"):
		var projectile_instance = projectile.instantiate()
		get_tree().current_scene.add_child(projectile_instance)
		
		var mouse_pos := get_global_mouse_position()
		projectile_instance.global_position = global_position + (sprite.texture.get_width() as float / 1.5) * (mouse_pos - global_position).normalized()
		projectile_instance.look_at(mouse_pos)
		projectile_instance.rotate(PI / 2)
		
func _physics_process(delta):
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and (is_on_floor() or climbing):
		if climbing:
			climbing = false
			vine_being_climbed.currently_being_climbed = false
			vine_being_climbed = null
			reparent(get_tree().current_scene)
		velocity.y = JUMP_VELOCITY

	var vertical_direction = Input.get_axis("climb_down", "climb_up")
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
		reparent(get_tree().current_scene)
	
	if climbing:
		global_rotation_degrees = 0
		position.x = 0
		
	# Add the gravity.
	if not is_on_floor() and not climbing:
		velocity.y += gravity * delta
	
	# Get the input horizontal_direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.a
	var horizontal_direction = Input.get_axis("move_left", "move_right")
	if horizontal_direction:
		if not climbing:
			velocity.x = horizontal_direction * SPEED * delta
		else:
			var vine_segment := get_parent() as RigidBody2D
			if vine_segment.get_parent().swingable:
				vine_segment.apply_impulse(swing_strength * horizontal_direction * delta * global_transform.x)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	move_and_slide()
