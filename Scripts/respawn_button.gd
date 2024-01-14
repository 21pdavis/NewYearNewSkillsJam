extends TextureButton

func _on_pressed():
	Engine.time_scale = 1
	get_tree().change_scene_to_file("res://Scenes/Michael.tscn")
