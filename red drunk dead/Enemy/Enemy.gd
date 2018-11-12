extends KinematicBody

# Physics
var Gravity = -70
var Health = 400
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
var InTheZone = true

const TYPE = "ENEMY"

func rot(DirVect):
	
	if DirVect.x == 0 && DirVect.z == -1:
		return 180
	elif DirVect.x == 1 && DirVect.z == 0:
		return 90
	elif DirVect.x == 0 && DirVect.z == 1:
		return 0
	elif DirVect.x == -1 && DirVect.z == 0:
		return -90
	elif DirVect.x == 1 && DirVect.z == 1:
		return 45
	elif DirVect.x == -1 && DirVect.z == 1:
		return -45
	elif DirVect.x == -1 && DirVect.z == -1:
		return -135
	elif DirVect.x == 1 && DirVect.z == -1:
		return 135

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
	
	if CanMove && InTheZone:
		if is_on_wall() && !BodyPos:
			var TempDir = Direction
			Direction *= -1
			TempDir.y = 0
			TempDir.x = ceil(TempDir.x)
			TempDir.z = ceil(TempDir.z)
			
			if TempDir.x == 0 && TempDir.z == 0:
				pass
			else:
				TempDir *= -1
				rotation_degrees.y = rot(TempDir) 
		
		Velocity = move_and_slide(Velocity, Vector3(0, 1, 0), 0.05, 4, deg2rad(MAXSLOPEANGLE))
	elif BeenShot:
		Velocity = move_and_slide(DirectionVector, Vector3(0, 1, 0), 0.05, 4, deg2rad(MAXSLOPEANGLE))
	
	if Health <= 0:
		#remove this later
		queue_free()
	
	if BodyPos:
		var value = 0.2
		value += delta
		var LookDir = (BodyPos.translation - translation) * -1
		var RotTrans = get_transform().looking_at(get_transform().origin + LookDir, Vector3 (0,1,0))
		var ThisRot = Quat(get_transform().basis).slerp(RotTrans.basis, value)
		
		if value > 1:
			value = 1
		
		set_transform(Transform(ThisRot, translation))

func _on_Timer_timeout():
	randomize()
	Direction.x = randi() % 3 - 1
	Direction.z = randi() % 3 - 1
	var TempDir = Direction
	TempDir.x = ceil(Direction.x)
	TempDir.z = ceil(Direction.z)
	

	if Direction.z == 0 && Direction.x == 0:
		pass
	else:
		rotation_degrees.y = rot(TempDir)
		print(rotation_degrees.y)
	
	
func bullet_hit(damage, bullet_global_transform):
	Health -= damage
	CanMove = false
	BeenShot = true
	$KnockTimer.start()
	
	DirectionVector = -bullet_global_transform.basis.y.normalized() * BASE_BULLET_BOOST
	DirectionVector.y = 3
	var TempDir = DirectionVector.normalized()
	TempDir.y = 0
	TempDir.x = ceil(TempDir.x)
	TempDir.z = ceil(TempDir.z)


	if TempDir.x == 0 && TempDir.z == 0:
		pass
	elif BeenShot && !BodyPos:
		print(TempDir)
		TempDir *= -1
		rotation_degrees.y = rot(TempDir) 
	
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
				$Timer.start()

func _on_ShootTimer_timeout():
	CanFire = true

func _on_Area_body_entered(body):
	if body.get("TYPE") == "PLAYER":
		$Timer.stop()
		BodyPos = body
		return
	
func _on_Area_body_exited(body):
	if body.get("TYPE") == "PLAYER":
		$Timer.start()
		BodyPos = null
		rotation_degrees.x = 0
		var TempDir = Direction
		TempDir.y = 0
		TempDir.x = ceil(TempDir.x)
		TempDir.z = ceil(TempDir.z)
		
		if TempDir.x == 0 && TempDir.z == 0:
			pass
		else:
			
			rotation_degrees.y = rot(TempDir)

func _on_Spawner_body_exited(body):
	$ExitTimer.start(2)
	if body.get("TYPE") == "ENEMY":
		print("left zone, returning")
		
		var TempDir = Direction
		Direction *= -1
		TempDir.y = 0
		TempDir.x = ceil(TempDir.x)
		TempDir.z = ceil(TempDir.z)
		
		if TempDir.x == 0 && TempDir.z == 0:
			pass
		else:
			TempDir *= -1
			rotation_degrees.y = rot(TempDir) 


func _on_ExitTimer_timeout():
	$Timer.start(2)