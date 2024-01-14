extends Node2D

@onready var teleporter1_interaction := $Teleporter1/InteractionArea as Area2D
@onready var teleporter2_interaction := $Teleporter2/InteractionArea as Area2D
@onready var state_machine1 = $Teleporter1/AnimationTree.get("parameters/playback")
@onready var state_machine2 = $Teleporter2/AnimationTree.get("parameters/playback")

var global_player = null

func _ready():
	state_machine1.travel("idle")
	state_machine2.travel("idle")

func _process(delta):
	var t1_bodies := teleporter1_interaction.get_overlapping_bodies()
	
	if t1_bodies:
		var player := find_player(t1_bodies)
		if player and Input.is_action_just_pressed("interact"):
			global_player = player
			state_machine1.travel("send")
			
func _on_animation_tree_animation_send_finished(anim_name):
	if anim_name == "send":
		global_player.global_position = teleporter2_interaction.global_position - 2 * global_transform.y
		global_player = null
		state_machine1.travel("idle")
		
		state_machine2.travel("receive")

func _on_animation_tree_animation_received_finished(anim_name):
	if anim_name == "receive":
		state_machine2.travel("idle")

func find_player(nodes: Array[Node2D]) -> Node2D:
	for node in nodes:
		if "player" in node.get_groups():
			return node
	return null

func _on_animation_tree_animation_send_started(anim_name):
	if anim_name == "send" and name == "EndTeleporter":
		var commander := get_tree().current_scene.get_node("Commander") as Node2D
		var commander_text := get_tree().current_scene.get_node("CommanderText") as Node2D
		var commander_spawn := (get_tree().current_scene.get_node("CommanderEndPoint") as Node2D).global_position
		
		var start_text = commander_text.get_node("StartText") as RichTextLabel
		var end_text = commander_text.get_node("EndText") as RichTextLabel
		start_text.visible = false
		end_text.visible = true
		commander.global_position = commander_spawn
		
		var start_teleporter = get_tree().current_scene.get_node("StartTeleporter")
		if start_teleporter:
			start_teleporter.queue_free()
