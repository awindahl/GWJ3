extends Spatial

func _on_Area_body_entered(body):
	if body.get("TYPE") == "PLAYER":
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_tree().change_scene("res://Saloon/WinScreen.tscn")