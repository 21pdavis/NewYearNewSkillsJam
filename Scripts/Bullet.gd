extends Area2D


var bullet_velocity = Vector2(1,0)
var speed

@onready var sprite := $Sprite2D as Sprite2D
@onready var sprite_width := sprite.texture.get_width() as float
@onready var prev_position := global_position

var global_ray_start
var global_ray_end

func _process(delta):
	queue_redraw()

func direction(direct:bool):
	if direct == true:
		speed = 500
	if direct == false:
		speed = -500

func _physics_process(delta):
	position += (bullet_velocity.normalized() * delta * speed)
	
	var space_state = get_world_2d().direct_space_state
	var ray_start := global_position + sprite_width * (-transform.x if speed == 500 else transform.x)
	var ray_end := prev_position + sprite_width * (transform.x if speed == 500 else -transform.x)
	var query := PhysicsRayQueryParameters2D.create(ray_start, prev_position)
	var result = space_state.intersect_ray(query)
	
	if result:
		var intersected_object := result.collider as Node2D
		if "vine_segment" in intersected_object.get_groups():
			print('in result')
			var vine = intersected_object.get_parent()
			if not vine.currently_being_climbed:
				var segment_index = vine.segments.find(intersected_object)
				vine.sever_segment(segment_index)
			
	prev_position = global_position
	
func destroy():
	queue_free()

func _on_area_entered(area):
	#print("area")
	##print(area.name)
	#if "Enemy" in area.get_groups():
		#area.take_damage(20)
	destroy()


func _on_body_entered(body):
	#destroy()
	#print("body")
	#print(body.name)
	if "Enemy" in body.get_groups():
		body.take_damage(20)
		destroy()
	
	if "vine_segment" in body.get_groups():
		var vine = body.get_parent()
		var segment_index = vine.segments.find(body)
		vine.sever_segment(segment_index)


func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
