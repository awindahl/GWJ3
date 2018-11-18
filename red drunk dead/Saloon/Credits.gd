extends StaticBody

#warning-ignore:unused_argument
#warning-ignore:unused_argument
func bullet_hit(damage, bullet_global_transform):
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	transition.fade_to("res://Saloon/Creditspage.tscn")
