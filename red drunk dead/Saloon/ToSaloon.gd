extends Button

func _on_ToSaloon_button_down():
#warning-ignore:return_value_discarded
	Global.Cash += 200
	get_tree().change_scene("res://Saloon/SaloonGame.tscn")

