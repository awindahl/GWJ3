extends KinematicBody

# Standards
const IDLE = 0
const WALK = 1
const SPRINT = 2
const BASE_BULLET_BOOST = 25
const TYPE = "PLAYER"

var Health = Global.Health
var CanFire = true
var CanMove = true
var BeenShot = false
var DAMAGE = Global.DAMAGE
var MovementState = IDLE
var LastFloorHeight
var CanChangeLastFloorHeight = true
var DirectionVector
var Status = ["SOBER", "DRUNK"]
var CurrentStatus = Status[0]
var Ammo = Global.Ammo
var MaxAmmo = Global.MaxAmmo
var Drunkeness = Global.Drunkeness
var Cash = Global.Cash

const STAND = 0
const CROUCH = 1

var Posture = STAND

var Direction = Vector3()
var WalkSpeed = Global.WalkSpeed
var SprintSpeed = Global.SprintSpeed
var MoveSpeed = WalkSpeed
var Velocity = Vector3()
var IsShooting = false

# Mouse
var Yaw = 0
var Pitch = 0
var ViewSensitivity = 0.15

# Physics
var Gravity = -70

const ACCELERATION = 0.5
const DECELERATION = 0.5
const MAXSLOPEANGLE = 60
const JUMP = 20

# Ladder - TODO
var OnLadder = false
const LADDERSPEED = 8
const LADDERACCELERATION = 2

# Stairs - TODO
const MAXSTAIRSLOPE = 20
const STAIRJUMP = 12

var temp = true
var RandomMovement
var FrameVar = 0
var MyEffect = Global.MyEffect
var fiveshot = false

# Setup
func _ready():
	randomize()
	# Get the mouse
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	MoveSpeed = WalkSpeed
	effect(Global.Effect)

func takeDamage(ammount):
	get_node("hurt"+str(randi() % 2 + 1)).play()
	Health -= ammount

func enemyMissed():
	get_node("Yaw/whiz"+str(randi() % 3 + 1)).play()
	
func _physics_process(delta):
	
	# TODO - check if on ladder
	_process_movement(delta)
	_shoot()
	
	if Health > 100:
		if FrameVar > 100:
			Health -= 1
	
	if Drunkeness > 0.1:
		if FrameVar > 100:
			Drunkeness -= 0.1
			FrameVar = 0
		CurrentStatus = "DRUNK"
		WalkSpeed = Global.WalkSpeed + (Drunkeness/3)
		SprintSpeed = Global.SprintSpeed + (Drunkeness/3)
		RandomMovement = Vector3(1, 0, 1)
		
		if temp:
			$AnimationPlayer.play("Shake")
			temp = false
	else:
		temp = true
		$AnimationPlayer.stop()
		WalkSpeed = Global.WalkSpeed * 0.5
		SprintSpeed = Global.SprintSpeed * 0.5

# Self Exlpanatory
func _apply_gravity(delta):
	Velocity.y += delta * Gravity

# cool function B-) 
func effect(effect):
	for effects in MyEffect:
		if effects == effect[0]:
			FrameVar -= 1
		if effects == effect[1]:
			Global.MaxAmmo = 12
			Global.Ammo = 12
			MaxAmmo = Global.MaxAmmo
			Ammo = Global.Ammo
			var rand = randi()%101 + 1
			if rand == 1:
				Input.action_press("shoot", 1)
		if effects == effect[2]:
			if Input.is_action_just_pressed("shoot"):
					$GunCoolDown.wait_time = 0.2
					fiveshot = true
		if effects == effect[3]:
			$GunCoolDown.wait_time = 0.2
		
# Payoff
func _process_movement(delta):
	# Inputs
	var Up = Input.is_action_pressed("ui_up")
	var Down = Input.is_action_pressed("ui_down")
	var Left = Input.is_action_pressed("ui_left")
	var Right = Input.is_action_pressed("ui_right")
	var Jump = Input.is_action_just_pressed("Jump")
	var Sprint = Input.is_action_pressed("Sprint")
	var Aim = $Yaw/Camera.get_camera_transform().basis
	
	Direction = Vector3()
	Cash = Global.Cash
	
	if Up:
		Direction -= Aim[2]
	if Down:
		Direction += Aim[2]
	if Left:
		Direction -= Aim[0]
	if Right:
		Direction += Aim[0]
	
	# Is Moving
	if Up or Down or Left or Right:
		if Posture == STAND:
			MovementState = WALK
			MoveSpeed = WalkSpeed
			if !OnLadder:
				if Up or Left or Right: # Only Sprint while moving forward
					if Sprint:
						MovementState = SPRINT
						MoveSpeed = SprintSpeed
	else: # Not Moving
		MovementState = IDLE
	
	var Normal
	if $FloorCheck.is_colliding():
		Normal = $FloorCheck.get_collision_normal()
	else:
		Normal = Vector3(0,0,0)
	
	# Fall Damage and Gravity
	if Normal.y > 0:
		if !CanChangeLastFloorHeight:
			var HeightDifference = LastFloorHeight - get_translation().y
			if HeightDifference > 8:
				#Health -= 10
				takeDamage(10)
		CanChangeLastFloorHeight = true
		Velocity -= Velocity.dot(Normal) * Normal
		
		if Jump: # Jump higher when sprinting
			get_node("jump"+str(randi()%2+1)).play()
			if MovementState == SPRINT:
				Velocity.y += JUMP * 1.1
			else:
				Velocity.y += JUMP
	else:
		_apply_gravity(delta)
		if CanChangeLastFloorHeight:
			LastFloorHeight = get_translation().y
			CanChangeLastFloorHeight = false
		
	# Stairs Code Magic
	if Direction.length() > 0 and $Yaw/Camera/StairCheck.is_colliding():
		var StairNormal = $Yaw/Camera/StairCheck.get_collision_normal()
		var StairAngle = rad2deg(acos(StairNormal.dot(Vector3(0, 1, 0))))
		if StairAngle == 0:
			Velocity.y = STAIRJUMP
	
	Direction.y = 0
	Direction = Direction.normalized()
	
	# Movement and Acceleration
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
	
	$Hud/Ammo.text = "\n" + var2str(Ammo) + "/" + var2str(MaxAmmo)
	if Drunkeness > 0.1:
		$Hud/Drunk.text = "\n" + var2str(Drunkeness) + "‰"
	else:
		$Hud/Drunk.text = "\n" + "0.0‰"
	$Hud/Health.text = "\n" + "+" + var2str(Health)
	
	$Hud/Cash.text = "$" + var2str(Cash)
	
	#here be game over
	if Health <= 0:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_tree().change_scene("res://Saloon/LoseScreen.tscn")
	
	if Input.is_action_just_pressed("r") && $ReloadTimer.time_left == 0 && Ammo < MaxAmmo && !IsShooting:
		$Yaw/reload.play()
		$ReloadTimer.start()
		$Yaw/Camera/revolver/AnimationPlayer.play("reload")
	
	if CanMove:
		Velocity = move_and_slide(Velocity, Vector3(0, 1, 0), 0.05, 4, deg2rad(MAXSLOPEANGLE))
	elif BeenShot:
		Velocity = move_and_slide(DirectionVector, Vector3(0, 1, 0), 0.05, 4, deg2rad(MAXSLOPEANGLE))
	
	FrameVar += 2
	
# Camera Movements
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		Yaw = fmod(Yaw - event.relative.x * ViewSensitivity, 360)
		Pitch = max(min(Pitch - event.relative.y * ViewSensitivity, 80), -80)
		$Yaw.rotation = Vector3(0, deg2rad(Yaw), 0)
		$Yaw/Camera.rotation = Vector3(deg2rad(Pitch), 0, 0)

func _shoot():
	#should only be called once
	if Input.is_action_just_pressed("shoot") && CanFire && Ammo && $ReloadTimer.time_left == 0 && !fiveshot:
		IsShooting = true
		Ammo -= 1
		$Yaw.get_node("gunshot"+str(randi() % 3 + 1)).play()
		$Yaw/Camera/revolver.get_node("AnimationPlayer").play("shoot")
		$Yaw/Camera/revolver/GunCheck.force_raycast_update()
		CanFire = false
		$GunCoolDown.start()
		
		if $Yaw/Camera/revolver/GunCheck.is_colliding():
			var body = $Yaw/Camera/revolver/GunCheck.get_collider()
			
			if body == null:
				pass
			
			elif body.has_method("bullet_hit"):
				body.bullet_hit(DAMAGE, $Yaw/Camera/revolver/GunCheck.global_transform)
	
	elif Input.is_action_pressed("shoot") && fiveshot && Ammo && $ReloadTimer.time_left == 0 && CanFire:
		CanFire = false
		Ammo -= 1
		$GunCoolDown.start()
		$Yaw/Camera/revolver.get_node("AnimationPlayer").play("shoot")
		if $Yaw/Camera/revolver/GunCheck.is_colliding():
			var body = $Yaw/Camera/revolver/GunCheck.get_collider()
			
			if body == null:
				pass
			
			elif body.has_method("bullet_hit"):
				body.bullet_hit(DAMAGE, $Yaw/Camera/revolver/GunCheck.global_transform)
		
func _on_GunCoolDown_timeout():
	CanFire = true
	IsShooting = false

func bullet_hit(damage, bullet_global_transform):
	#Health -= damage
	takeDamage(damage)
	CanMove = false
	$MoveTimer.start()
	
	DirectionVector = bullet_global_transform.basis.y.normalized() * BASE_BULLET_BOOST
	DirectionVector.y = 3
	BeenShot = true

func _on_MoveTimer_timeout():
	CanMove = true
	BeenShot = false

func _on_ReloadTimer_timeout():
	Ammo = Global.MaxAmmo
	return