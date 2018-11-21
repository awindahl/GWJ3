extends KinematicBody

# Physics
var Gravity = -70
export var Health = 50
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
export var DAMAGE = 20
var BodyPos
var BeenShot = false
var bottle
var spawn
var isDead = false
const TYPE = "ENEMY"

func _ready():
	$Mesh/AnimationPlayer.play("idle-loop")
	bottle = preload("res://Assets/Imported Objects/Bottle.tscn") 

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
	if DirectionVector != null:
		DirectionVector.y += delta * Gravity
		
func _process(delta):
	
	_apply_gravity(delta)
	_shoot()
	
	Direction.y = 0
	Direction = Direction.normalized()
	
	var Normal
	if $FloorCheck.is_colliding():
		Normal = $FloorCheck.get_collision_normal()
	else:
		Normal = Vector3(0,0,0)
	
	# Fall Damage and Gravity
	if Normal.y == 0:
		pass
	else:
		_apply_gravity(delta)
	
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

	if !BeenShot && CanMove:
		Velocity = move_and_slide(Velocity, Vector3(0, 1, 0), 0.05, 4, deg2rad(MAXSLOPEANGLE))
	
	if Health <= 0:
		isDead = true
		_apply_gravity(delta)
		$Mesh/AnimationPlayer.play("die")
		die()
	
	if BodyPos:
		var LastRot = rotation_degrees
		var value = 0.2
		value += delta
		var LookDir = (BodyPos.translation - translation) * -1
		var RotTrans = get_transform().looking_at(get_transform().origin + LookDir, Vector3 (0,1,0))
		var ThisRot = Quat(get_transform().basis).slerp(RotTrans.basis, value)
		ThisRot.normalized()
		if value > 1:
			value = 1
		
		set_transform(Transform(ThisRot, translation))
		rotation_degrees.x = LastRot.x
	
func _on_Timer_timeout():
	if CanMove && !BodyPos:
		$Mesh/AnimationPlayer.play("walk-loop")
		randomize()
		Direction.x = randi() % 3 - 1
		Direction.z = randi() % 3 - 1
		var TempDir = Direction
		TempDir.x = ceil(Direction.x)
		TempDir.z = ceil(Direction.z)
		
		if Direction.z == 0 && Direction.x == 0:
			#$Mesh/AnimationPlayer.play("idle-loop")
			pass
		else:
			rotation_degrees.y = rot(TempDir)
	else:
		pass

func bullet_hit(damage, bullet_global_transform):
	get_node("hurt"+str(randi()%2+1)).play()
	Health -= damage
	CanMove = false
	BeenShot = true
	$KnockTimer.paused = false
	$Timer.paused = true
	
	DirectionVector = -bullet_global_transform.basis.y.normalized() * BASE_BULLET_BOOST
	DirectionVector.y = 3
	var TempDir = DirectionVector.normalized()
	TempDir.y = 0
	TempDir.x = ceil(TempDir.x)
	TempDir.z = ceil(TempDir.z)
	
	if TempDir.x == 0 && TempDir.z == 0:
		pass
	if BeenShot && !BodyPos:
		
		$Hindsight/CollisionShape.disabled = false
		

func _on_KnockTimer_timeout():
	if !BodyPos:
		CanMove = true
	BeenShot = false
	$Timer.paused = false
	
func _shoot():
	$Area/GunCast.force_raycast_update()
	#should only be called once
	if CanFire:
		if $Area/GunCast.is_colliding():
			var body = $Area/GunCast.get_collider()
			if body == null:
				pass
			
			elif body.has_method("bullet_hit") && body.get("TYPE") == "PLAYER":
				randomize()
				CanFire = false
				$ShootTimer.start()
				get_node("shoot"+str(randi()%3+1)).play()
				$Mesh/AnimationPlayer.play("shoot")
				var random = randi()%11 + 1
				if random > 4:
					body.bullet_hit(DAMAGE, $Area/GunCast.global_transform)
				else:
					body.enemyMissed()
			
			elif BodyPos && body.get("TYPE") == "BARREL":
				CanFire = false
				$ShootTimer.start()
				get_node("shoot"+str(randi()%3+1)).play()
				body.bullet_hit(DAMAGE, $Area/GunCast.global_transform)
			
func _on_ShootTimer_timeout():
	CanFire = true

func _on_Area_body_entered(body):
	if body.get("TYPE") == "PLAYER" && CanMove && !isDead:
		CanMove = false
		$Hindsight/CollisionShape.disabled = true
		$Timer.paused = true
		get_node("spotted"+str(randi()%3+1)).play()
		BodyPos = body
	
func _on_Area_body_exited(body):
	if body.get("TYPE") == "PLAYER" && !CanMove && !isDead:
		CanMove = true
		$Timer.paused = false
		#BodyPos = null
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
	$ExitTimer.paused = false
	if body.get("TYPE") == "ENEMY":
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
	$Timer.paused = false

func _on_Hindsight_body_entered(body):
	if body.get("TYPE") == "PLAYER":
		CanMove = false
		$Timer.paused = true
		get_node("spotted"+str(randi()%3+1)).play()
		BodyPos = body
		return

func _on_Hindsight_body_exited(body):
	if body.get("TYPE") == "PLAYER":
		BodyPos = null
		return

func die():
	get_node("die"+str(randi()%4+1)).play()
	CanMove = false
	set_process(false)
	$Timer.paused = true
	$KnockTimer.paused = true
	$ShootTimer.paused = true
	$CollisionShape.disabled = true
	CanFire = false
	$Area/CollisionShape.disabled = true
	$Hindsight/CollisionShape.disabled = true
	$ExitTimer.paused = true
	#BodyPos = null
	
	randomize()
	var random = randi()% 11 + 1
	
	if random > 5:
		spawn = bottle.instance()
		spawn.translation.y = -3
		add_child(spawn)
		spawn.get_node("AnimationPlayer").play("Spin")