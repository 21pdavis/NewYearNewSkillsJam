extends RigidBody2D

signal init_vine

@export var segments: int

# TODO: multiple connection points
#@onready var vine_connection_point: Node2D = $VinePoint
@onready var vine_raycast: RayCast2D = $VineRaycast
var vine_ref := preload("res://Scenes/Presets/vine.tscn")
var vine_instance: Node2D
var vine_spawned: bool

# DEBUG
var debug_intersection_point := Vector2.ZERO

func _ready():
	assert(vine_ref, "Vine scene not loaded correctly.")

func _process(delta):
	queue_redraw()

# TODO: refactor with Raycast2D node
func _physics_process(delta):
	if vine_raycast.is_colliding() and not vine_spawned:
		var intersection_point := vine_raycast.get_collision_point()
		
		# DEBUG
		debug_intersection_point = intersection_point
		
		vine_instance = vine_ref.instantiate() as Node2D
		get_tree().current_scene.add_child(vine_instance)
		vine_instance.position = intersection_point
		# TODO: global?
		vine_instance.draw_vine(vine_raycast)
		vine_spawned = true;
		
#func _draw():
	#if debug_intersection_point != Vector2.ZERO:
		#draw_circle(to_local(debug_intersection_point), 2, Color.GREEN)
