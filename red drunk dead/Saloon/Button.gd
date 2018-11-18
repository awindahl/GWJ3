extends Sprite3D

var temp = 0
var cost = 0

func _ready():
	if name == "Confederate Charisma":
		cost = 25
	if name == "Gunfire":
		cost = 210
	if name == "Five Shooter":
		cost = 300
	if name == "Yankee Yipee":
		cost = 50

#warning-ignore:unused_argument
#warning-ignore:unused_argument
#warning-ignore:unused_argument
#warning-ignore:unused_argument
func _on_StaticBody_input_event(camera, event, click_position, click_normal, shape_idx):
	if event is InputEventMouseButton:
		# Only run this once
		if temp == 0 && get_parent().get_parent().get_parent().get_node("Player").Cash >= cost:
			temp += 1
			get_parent().get_parent().get_node("AnimationPlayer").play_backwards("Move")
			get_parent().get_parent().get_parent().get_node("Player").CanMoveCam = true
			get_parent().get_parent().get_parent().get_node("Player").set_process(true)
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			
			get_parent().get_parent().get_parent().get_node("Player").text = ""
			Global.MyEffect.append(name)
			Global.Drunkeness += 10
			Global.Cash -= cost
			get_parent().get_parent().get_parent().drink()
		else:
			temp = 0
	

func _on_StaticBody_mouse_entered():
	get_parent().get_parent().get_parent().get_node("Player").text = name + " $" + var2str(cost)

func _on_StaticBody_mouse_exited():
	get_parent().get_parent().get_parent().get_node("Player").text = ""
