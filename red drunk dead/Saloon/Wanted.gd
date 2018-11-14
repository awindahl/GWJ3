extends StaticBody

#warning-ignore:unused_argument
#warning-ignore:unused_argument
func bullet_hit(damage, bullet_global_transform):
	$AnimationPlayer.play("Move")
	get_parent().get_node("Player").CanMoveCam = false
	get_parent().get_node("Player").set_process(false)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
