extends Sprite3D

var temp = 0

#warning-ignore:unused_argument
#warning-ignore:unused_argument
#warning-ignore:unused_argument
#warning-ignore:unused_argument
func _on_StaticBody_input_event(camera, event, click_position, click_normal, shape_idx):
	if event is InputEventMouseButton:
		# Only run this once
		if temp == 0:
			temp += 1
			print(name)
			get_parent().get_parent().get_node("AnimationPlayer").play_backwards("Move")
			get_parent().get_parent().get_parent().get_node("Player").CanMoveCam = true
			get_parent().get_parent().get_parent().get_node("Player").set_process(true)
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
#warning-ignore:return_value_discarded
			transition.fade_to("res://TestLevel"+str(randi()%4+1)+".tscn")
			#transition.fade_to("res://TestLevel1.tscn")
			#get_tree().change_scene("res://TestLevel"+str(randi()%4+1)+".tscn")
		else:
			temp = 0
	