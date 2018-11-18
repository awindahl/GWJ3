extends Button

func _on_ToSaloon_button_down():
#warning-ignore:return_value_discarded
	Global.Drunkeness = 0
	Global.Cash += 200
	Global.MyEffect.clear()
	get_tree().change_scene("res://Saloon/SaloonGame.tscn")

