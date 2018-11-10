extends KinematicBody

# Physics
var Gravity = -70
var Direction = Vector3()
var WalkSpeed = 15
var MoveSpeed = WalkSpeed
const MAXSLOPEANGLE = 60
var Velocity = Vector3()
const ACCELERATION = 0.5
const DECELERATION = 0.5
const BASE_BULLET_BOOST = 9

# Self Exlpanatory
func _apply_gravity(delta):
	Velocity.y += delta * Gravity

func _process(delta):
	
	_apply_gravity(delta)

	Direction.y = 0
	Direction = Direction.normalized()
	
	var hVel = Velocity
	hVel.y = 0
	var Target = Direction * MoveSpeed
	var Acceleration
	if Direction.dot(hVel) > 0:
		Acceleration = ACCELERATION
	else:
		Acceleration = DECELERATION
	
	hVel = hVel.linear_interpolate(Target, Acceleration * MoveSpeed * delta)
	Velocity.x = hVel.x
	Velocity.z = hVel.z
	
	Velocity = move_and_slide(Velocity, Vector3(0, 1, 0), 0.05, 4, deg2rad(MAXSLOPEANGLE))
	

func _on_Timer_timeout():
	randomize()
	Direction.x = randi() % 3 - 1
	Direction.z = randi() % 3 - 1

func bullet_hit(damage, bullet_global_transform):
	print(self.name, "I've been hit!")
	
	var direction_vect = bullet_global_transform.basis.z.normalized() * BASE_BULLET_BOOST
	
	#move_and_slide((bullet_global_transform - global_transform.origin).normalized(), direction_vect * damage)