extends KinematicBody

# Physics
var Gravity = -70
var Health = 40
var Direction = Vector3()
var WalkSpeed = 10
var MoveSpeed = WalkSpeed
const MAXSLOPEANGLE = 60
var Velocity = Vector3()
const ACCELERATION = 0.5
const DECELERATION = 0.5
const BASE_BULLET_BOOST = 18
var CanMove = true
var direction_vect
var CanFire = true
var DAMAGE = 20

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
	
	if CanMove:
		if Direction.dot(hVel) > 0:
			Acceleration = ACCELERATION
		else:
			Acceleration = DECELERATION
		hVel = hVel.linear_interpolate(Target, Acceleration * MoveSpeed * delta)
		Velocity.x = hVel.x
		Velocity.z = hVel.z
	
	if CanMove:
		Velocity = move_and_slide(Velocity, Vector3(0, 1, 0), 0.05, 4, deg2rad(MAXSLOPEANGLE))
		
		
	else:
		Velocity = move_and_slide(direction_vect, Vector3(0, 1, 0), 0.05, 4, deg2rad(MAXSLOPEANGLE))
	
	if Health <= 0:
		#remove this later
		queue_free()
	
func _on_Timer_timeout():
	randomize()
	Direction.x = randi() % 3 - 1
	Direction.z = randi() % 3 - 1
	
	# UGLY
	if Direction.x == 0 && Direction.z == -1:
		rotation_degrees.y = 0
	elif Direction.x == 1 && Direction.z == 0:
		rotation_degrees.y = -90
	elif Direction.x == 0 && Direction.z == 1:
		rotation_degrees.y = 180
	elif Direction.x == -1 && Direction.z == 0:
		rotation_degrees.y = 90
	elif Direction.x == 1 && Direction.z == 1:
		rotation_degrees.y = -135
	elif Direction.x == -1 && Direction.z == 1:
		rotation_degrees.y = 135
	elif Direction.x == -1 && Direction.z == -1:
		rotation_degrees.y = 45
	elif Direction.x == 1 && Direction.z == -1:
		rotation_degrees.y = -45

func bullet_hit(damage, bullet_global_transform):
	Health -= damage
	CanMove = false
	$KnockTimer.start()
	
	direction_vect = -bullet_global_transform.basis.y.normalized() * BASE_BULLET_BOOST
	direction_vect.y = 3
	
func _on_KnockTimer_timeout():
	CanMove = true
	
func _shoot():
	#should only be called once
	if CanFire:
		$GunCast.force_raycast_update()
		CanFire = false
		$ShootTimer.start()
		
		if $GunCast.is_colliding():
			var body = $GunCast.get_collider()
			
			if body == null:
				pass
			
			elif body.has_method("bullet_hit"):
				body.bullet_hit(DAMAGE, $GunCast.global_transform)

func _on_ShootTimer_timeout():
	CanFire = true