extends Area2D

@export var speed: float

@onready var sprite := $Sprite as Sprite2D
@onready var sprite_height := sprite.texture.get_height() as float
@onready var prev_position := global_position

func _ready():
	add_to_group("vine_slicer")

# a reference for a good method for drawing (do everything global, then convert to local)
#func _draw():
	#var ray_start = to_local(global_position + (sprite_height / 2) * transform.y)
	#var ray_end = to_local(prev_position + (sprite_height / 2) * transform.y)
	#draw_line(ray_start, ray_end, Color.WEB_PURPLE, 1)
	
func _physics_process(delta):
	var space_state = get_world_2d().direct_space_state
	var ray_start := global_position + (sprite_height / 2) * transform.y
	var ray_end := prev_position + (sprite_height / 2) * transform.y
	var query := PhysicsRayQueryParameters2D.create(ray_start, prev_position)
	var result = space_state.intersect_ray(query)
	
	if result:
		var intersected_object := result.collider as Node2D
		if "vine_segment" in intersected_object.get_groups():
			var vine = intersected_object.get_parent()
			var segment_index = vine.segments.find(intersected_object)
			vine.sever_segment(segment_index)
			
	prev_position = global_position

func _process(delta):
	position += speed * delta * (-transform.y)
	queue_redraw()
