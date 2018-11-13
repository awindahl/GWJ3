extends StaticBody

const MAXSLOPEANGLE = 60
const TYPE = "BARREL"

#warning-ignore:unused_argument
#warning-ignore:unused_argument
func bullet_hit(damage, bullet_global_transform):
	$AnimationPlayer.play("Explode", -1, 0.5)
