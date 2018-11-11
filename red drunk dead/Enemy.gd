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
const BASE_BULLET_BOOST = 40
var CanMove = true
var DirectionVector
var CanFire = true
var DAMAGE = 20
var BodyPos
var BeenShot = false

const TYPE = "ENEMY"

# Self Exlpanatory
func _apply_gravity(delta):
	Velocity.y += delta * Gravity

func _process(delta):
	
	_apply_gravity(delta)
	_shoot()

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
	elif BeenShot:
		Velocity = move_and_slide(DirectionVector, Vector3(0, 1, 0), 0.05, 4, deg2rad(MAXSLOPEANGLE))
	
	if Health <= 0:
		#remove this later
		queue_free()
	
	if BodyPos:
		
		var value = 0.05
		value += delta
		var LookDir = (BodyPos.translation - translation) * -1
		var RotTrans = get_transform().looking_at(get_transform().origin + LookDir, Vector3 (0,1,0))
		var ThisRot = Quat(get_transform().basis).slerp(RotTrans.basis, value)
		
		if value > 1:
			value = 1
		
		set_transform(Transform(ThisRot, translation))

func _on_Timer_timeout():
	randomize()
#	Direction.x = randi() % 3 - 1
#	Direction.z = randi() % 3 - 1
#

func bullet_hit(damage, bullet_global_transform):
	Health -= damage
	CanMove = false
	BeenShot = true
	$KnockTimer.start()
	
	DirectionVector = -bullet_global_transform.basis.y.normalized() * BASE_BULLET_BOOST
	DirectionVector.y = 3
	
func _on_KnockTimer_timeout():
	CanMove = true
	BeenShot = false
	
func _shoot():
	$GunCast.force_raycast_update()
	#should only be called once
	if CanFire:
		CanFire = false
		$ShootTimer.start()
		
		if $GunCast.is_colliding():
			var body = $GunCast.get_collider()
			
			if body == null:
				pass
			
			elif body.has_method("bullet_hit") && body.get("TYPE") == "PLAYER":
				body.bullet_hit(DAMAGE, $GunCast.global_transform)
				print("im shooting")

func _on_ShootTimer_timeout():
	CanFire = true

func _on_Area_body_entered(body):
	if body.get("TYPE") == "PLAYER":
		var SpaceState = get_world().direct_space_state
		var Result = SpaceState.intersect_ray(translation, body.translation, [self], collision_mask)
		print (Result.size())
		BodyPos = body
		return

func _on_Area_body_exited(body):
	if body.get("TYPE") == "PLAYER":
		BodyPos = null
		rotation_degrees.x = 0
