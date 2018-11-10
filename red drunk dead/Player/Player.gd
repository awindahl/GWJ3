extends KinematicBody

# Standards
const IDLE = 0
const WALK = 1
const SPRINT = 2

var DAMAGE = 20
var MovementState = IDLE
var LastFloorHeight
var CanChangeLastFloorHeight = true

const STAND = 0
const CROUCH = 1

var Posture = STAND

var Direction = Vector3()
var WalkSpeed = 15
var SprintSpeed = 25
var MoveSpeed = WalkSpeed
var Velocity = Vector3()

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
	var Jump = Input.is_action_pressed("Jump")
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
	
	Velocity = move_and_slide(Velocity, Vector3(0, 1, 0), 0.05, 4, deg2rad(MAXSLOPEANGLE))
	

# func _process_on_ladder(delta)
#	pass

# Camera Movements
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		Yaw = fmod(Yaw - event.relative.x * ViewSensitivity, 360)
		Pitch = max(min(Pitch - event.relative.y * ViewSensitivity, 89), -89)
		$Yaw.rotation = Vector3(0, deg2rad(Yaw), 0)
		$Yaw/Camera.rotation = Vector3(deg2rad(Pitch), 0, 0)
	
	if Input.is_action_just_pressed("shoot"):
		$Yaw/Camera/GunCheck.force_raycast_update()
		
		if $Yaw/Camera/GunCheck.is_colliding():
			var body = $Yaw/Camera/GunCheck.get_collider()
			
			if body == null:
				pass
			
			elif body.has_method("bullet_hit"):
				body.bullet_hit(DAMAGE, $Yaw/Camera/GunCheck.global_transform)
				