extends CharacterBody2D


const SPEED = 6000
const JUMP_VELOCITY = -400.0

var projectile := preload("res://Scenes/Presets/test_projectile.tscn")
@onready var sprite := $Sprite as Sprite2D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _process(delta):
	if Input.is_action_just_pressed("fire"):
		var projectile_instance = projectile.instantiate()
		get_tree().current_scene.add_child(projectile_instance)
		
		var mouse_pos := get_global_mouse_position()
		projectile_instance.global_position = global_position + (sprite.texture.get_width() as float / 1.5) * (mouse_pos - global_position).normalized()
		projectile_instance.look_at(mouse_pos)
		
func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED * delta
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
