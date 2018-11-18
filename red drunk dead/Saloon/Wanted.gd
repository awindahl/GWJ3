extends StaticBody

var WantedBeenClicked = false

#warning-ignore:unused_argument
#warning-ignore:unused_argument
func bullet_hit(damage, bullet_global_transform):
	$AnimationPlayer.play("Move")
	get_parent().get_node("Player").CanMoveCam = false
	get_parent().get_node("Player").set_process(false)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	WantedBeenClicked = true

func _input(event):
	if event.is_action_pressed("ui_cancel") && WantedBeenClicked:
		get_node("AnimationPlayer").play_backwards("Move")
		get_parent().get_node("Player").CanMoveCam = true
		get_parent().get_node("Player").set_process(true)
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		WantedBeenClicked = false
