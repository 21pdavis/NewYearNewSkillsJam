extends RayCast2D

## True if the vine should be attached to the ray spawn point
@export var attached: bool = false

var vine_ref := preload("res://Scenes/Presets/vine.tscn")
var vine_instance: Node2D
var vine_spawned: bool

func _physics_process(delta):
	if is_colliding() and not vine_spawned:
		var intersection_point := get_collision_point()
		vine_instance = vine_ref.instantiate() as Node2D
		get_tree().current_scene.add_child(vine_instance)
		vine_instance.global_position = intersection_point
		vine_instance.generate_vine(attached, self)
		vine_spawned = true;
