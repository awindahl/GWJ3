extends CanvasLayer

var path = ""
var time = 1.0
var solo_fade = false

func _ready():
	$AnimationPlayer.play("fadeOut", -1, time)

func fade_to(scn_path, scn_time = 1.0):
	for i in get_tree().get_root().get_children():
		if i.get_name() != "transition":
			i.get_tree().set_pause(true)
			break

	self.path = scn_path # store the scene path
	self.time = scn_time
	$AnimationPlayer.play("fadeIn", -1, time) # play the transition animation

func fade_in(time = 1.0):
	solo_fade = true
	$AnimationPlayer.play("fadeIn", -1, time) # play the transition animation

func fade_out(time = 1.0):
	$AnimationPlayer.play("fadeOut", -1, time) # play the transition animation

func change_scene():
	if path != "":
		get_tree().change_scene(path)
		for i in get_tree().get_root().get_children():
			if i.get_name() != "transition":
				i.get_tree().set_pause(false)
				break

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "fadeIn" && !solo_fade:
		change_scene()
		$AnimationPlayer.play("fadeOut", -1, time)
	elif solo_fade:
		solo_fade = !solo_fade