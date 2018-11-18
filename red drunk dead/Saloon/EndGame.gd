extends Button

func _on_No_pressed():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	transition.fade_to("res://Saloon/SaloonGame.tscn")

func _on_Yes_pressed():
	get_tree().quit()