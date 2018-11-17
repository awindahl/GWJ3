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
			
			get_parent().get_parent().get_parent().get_node("Player").text = ""
			# enter different alcohols here
			Global.Drunkeness += 10
			Global.Cash -= 10
			get_parent().get_parent().get_parent().drink()
		else:
			temp = 0
	

func _on_StaticBody_mouse_entered():
	get_parent().get_parent().get_parent().get_node("Player").text = name

func _on_StaticBody_mouse_exited():
	get_parent().get_parent().get_parent().get_node("Player").text = ""
