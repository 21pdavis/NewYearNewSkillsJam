extends RigidBody2D

signal init_vine

@export var segments: int

# TODO: multiple connection points
@onready var vine_connection_point: Node2D = $VinePoint
var vine_ref := preload("res://Scenes/Presets/vine.tscn")
var vine_instance: Node2D
var spawned_vine: bool

func _ready():
	pass

func _physics_process(delta):
	# find spawn point of vine
	if not spawned_vine:
		var space_state := get_world_2d().direct_space_state
		var query := PhysicsRayQueryParameters2D.create(vine_connection_point.position, vine_connection_point.position - 1e6 * transform.y)
		var result := space_state.intersect_ray(query)

		# build vine
		if result:
			vine_instance = vine_ref.instantiate()
			vine_instance.position = result.position
			vine_instance.draw_vine(vine_connection_point.position)
			spawned_vine = true

func _draw():
	draw_line(vine_connection_point.position, vine_connection_point.position - 1e6 * transform.y, Color.GREEN, 1)

func _process(delta):
	pass
