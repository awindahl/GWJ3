extends StaticBody

const MAXSLOPEANGLE = 60
const TYPE = "BARREL"



#warning-ignore:unused_argument
#warning-ignore:unused_argument
func bullet_hit(damage, bullet_global_transform):
	$AnimationPlayer.play("Explode", -1, 0.5)
	
	randomize()
	var random = randi()% 11 + 1
	var bottle = preload("res://Assets/Imported Objects/Bottle.tscn") 
	
	if random > 5:
		var spawn = bottle.instance()
		add_child(spawn)
		spawn.get_node("AnimationPlayer").play("Spin")