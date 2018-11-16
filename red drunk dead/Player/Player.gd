extends KinematicBody

# Standards
const IDLE = 0
const WALK = 1
const SPRINT = 2
const BASE_BULLET_BOOST = 25
const TYPE = "PLAYER"

var Health = 10000
var CanFire = true
var CanMove = true
var BeenShot = false
var DAMAGE = 20
var MovementState = IDLE
var LastFloorHeight
var CanChangeLastFloorHeight = true
var DirectionVector
var Status = ["SOBER", "DRUNK"]
var CurrentStatus = Status[0]
var Ammo = 5
var Drunkeness = 0

const STAND = 0
const CROUCH = 1

var Posture = STAND

var Direction = Vector3()
var WalkSpeed = 15
var SprintSpeed = 25
var MoveSpeed = WalkSpeed
var Velocity = Vector3()
var IsShooting = false

# Mouse
var Yaw = 0
var Pitch = 0
var ViewSensitivity = 0.15
var LookVector = Vector3()

# Physics
var Gravity = -70

const ACCELERATION = 0.5
const DECELERATION = 0.5
const MAXSLOPEANGLE = 60
const JUMP = 15

# Ladder - TODO
var OnLadder = false
const LADDERSPEED = 8
const LADDERACCELERATION = 2

# Stairs - TODO
const MAXSTAIRSLOPE = 20
const STAIRJUMP = 6

var temp = true
var RandomMovement
var FrameVar = 0

# Setup
func _ready():
	# Get the mouse
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

#warning-ignore:unused_argument
func _process(delta):
	# Where the Player is Looking
	var dir = $Yaw/Camera/LookAt.get_global_transform().origin - $Yaw/Camera.get_global_transform().origin.normalized()
	LookVector = dir

func _physics_process(delta):
	# TODO - check if on ladder
	_process_movement(delta)
	_shoot()
	
	if Health > 100:
		if FrameVar > 100:
			Health -= 1
	
	if Input.is_action_just_pressed("1"):
		Drunkeness = 0
	if Input.is_action_just_pressed("2") && Drunkeness < 50:
		Drunkeness += 10
		temp = true
	
	if Drunkeness > 0.1:
		if FrameVar > 100:
			Drunkeness -= 0.1
			FrameVar = 0
		CurrentStatus = "DRUNK"
		WalkSpeed = 15 + (Drunkeness/3)
		SprintSpeed = 25 + (Drunkeness/3)
		RandomMovement = Vector3(1, 0, 1)
		
		if temp:
			$AnimationPlayer.play("Shake")
			temp = false
	else:
		temp = true
		$AnimationPlayer.stop()
		WalkSpeed = 15
		SprintSpeed = 25

# Self Exlpanatory
func _apply_gravity(delta):
	Velocity.y += delta * Gravity

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
				print("Ow")
		CanChangeLastFloorHeight = true
		Velocity -= Velocity.dot(Normal) * Normal
		
		if Jump: # Jump higher when sprinting
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
	if Direction.length() > 0 and $StairCheck.is_colliding():
		var StairNormal = $StairCheck.get_collision_normal()
		var StairAngle = rad2deg(acos(StairNormal.dot(Vector3(0, 1, 0))))
		if StairAngle < MAXSTAIRSLOPE:
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
	
	$Hud/Ammo.text = var2str(Ammo) + "/5"
	if Drunkeness > 0.1:
		$Hud/Drunk.text = var2str(Drunkeness) + "‰"
	else:
		$Hud/Drunk.text = "0.0‰"
	$Hud/Health.text = "+" + var2str(Health)
	
	#here be game over
	if Health <= 0:
		print("game over")
		queue_free()
	
	if Input.is_action_just_pressed("r") && $ReloadTimer.time_left == 0 && Ammo < 5 && !IsShooting:
		$ReloadTimer.start()
		$Yaw/Camera/revolver/AnimationPlayer.play("reload")
	
	if CanMove:
		Velocity = move_and_slide(Velocity, Vector3(0, 1, 0), 0.05, 4, deg2rad(MAXSLOPEANGLE))
	elif BeenShot:
		Velocity = move_and_slide(DirectionVector, Vector3(0, 1, 0), 0.05, 4, deg2rad(MAXSLOPEANGLE))
	
	FrameVar += 1
	
# Camera Movements
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		Yaw = fmod(Yaw - event.relative.x * ViewSensitivity, 360)
		Pitch = max(min(Pitch - event.relative.y * ViewSensitivity, 80), -80)
		$Yaw.rotation = Vector3(0, deg2rad(Yaw), 0)
		$Yaw/Camera.rotation = Vector3(deg2rad(Pitch), 0, 0)

func _shoot():
	#should only be called once
	if Input.is_action_just_pressed("shoot") && CanFire && Ammo && $ReloadTimer.time_left == 0:
		IsShooting = true
		Ammo -= 1
		$Yaw/Camera/revolver.get_node("AnimationPlayer").play("shoot")
		$Yaw/Camera/GunCheck.force_raycast_update()
		CanFire = false
		$GunCoolDown.start()
		
		if $Yaw/Camera/GunCheck.is_colliding():
			var body = $Yaw/Camera/GunCheck.get_collider()
			
			if body == null:
				pass
			
			elif body.has_method("bullet_hit"):
				body.bullet_hit(DAMAGE, $Yaw/Camera/GunCheck.global_transform)
		
func _on_GunCoolDown_timeout():
	CanFire = true
	IsShooting = false

func bullet_hit(damage, bullet_global_transform):
	Health -= damage
	CanMove = false
	$MoveTimer.start()
	
	DirectionVector = bullet_global_transform.basis.y.normalized() * BASE_BULLET_BOOST
	DirectionVector.y = 3
	BeenShot = true

func _on_MoveTimer_timeout():
	CanMove = true
	BeenShot = false


func _on_ReloadTimer_timeout():
	Ammo = 5
	return