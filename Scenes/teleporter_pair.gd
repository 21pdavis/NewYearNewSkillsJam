extends Node2D

@onready var teleporter1_interaction := $Teleporter1/InteractionArea as Area2D
@onready var teleporter2_interaction := $Teleporter2/InteractionArea as Area2D

func _process(delta):
	var t1_bodies := teleporter1_interaction.get_overlapping_bodies()
	var t2_bodies := teleporter2_interaction.get_overlapping_bodies()
	
	if t1_bodies:
		var player := find_player(t1_bodies)
		if player and Input.is_action_just_pressed("interact"):
			player.global_position = teleporter2_interaction.global_position - 2 * global_transform.y
	if t2_bodies:
		var player := find_player(t2_bodies)
		if player and Input.is_action_just_pressed("interact"):
			player.global_position = teleporter1_interaction.global_position - 2 * global_transform.y

func find_player(nodes: Array[Node2D]) -> Node2D:
	for node in nodes:
		if "player" in node.get_groups():
			return node
	return null
