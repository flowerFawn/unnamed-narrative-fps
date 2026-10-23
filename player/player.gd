extends CharacterBody3D
class_name Player

const BASE_SPEED:int = 1
const SPRINT_MULTIPLIER:float = 2
const TERMINAL_VELOCITY:int = 3
const GRAVITY:float = 9.8
const JUMP_FORCE:float = 5

enum PlayerState{
	WALKING,
	SPRINTING,
	AIRTIME,
	DISABLED,
}

##Head node of the player. Controls the camera and the players pitch/yaw.
@export var head:PlayerHead
##State of the player
var state:PlayerState


func _physics_process(delta: float) -> void:
	#checks if state needs to change at the start of this frame
	check_for_state_change()
	#runs the process for the current state
	print(state)
	match state:
		PlayerState.WALKING:
			walking_physics_process(delta)
		PlayerState.SPRINTING:
			walking_physics_process(delta, SPRINT_MULTIPLIER)
		PlayerState.AIRTIME:
			airtime_physics_process(delta)
		PlayerState.DISABLED:
			pass
	move_and_slide()

##Sets player velocity to the user movement inputs, rotated by the yaw of the head.
##This moves the player along the direction they are looking
func walking_physics_process(delta:float, multiplier:float = 1) -> void:
	var movement_input_vector:Vector2 
	var movement_vector:Vector2
	movement_input_vector = Input.get_vector("Move Forward", "Move Backward", "Strafe Left", "Strafe Right")
	movement_vector = movement_input_vector.rotated(head.yaw) * BASE_SPEED * multiplier
	velocity.x = movement_vector.y
	velocity.z = movement_vector.x
	

func airtime_physics_process(delta:float) -> void:
	if velocity.y > -TERMINAL_VELOCITY:
		velocity.y = max(-TERMINAL_VELOCITY, velocity.y - (GRAVITY * delta))
	
##Based on the current state, checks for factors that would cause state to change
##If walking or sprinting, checks for the player triggering a jump
##If in airtime, checks for hitting the floor
func check_for_state_change() -> void:
	#if statement rather than match case to allow for sharing some triggers between states but not all
	if state == PlayerState.AIRTIME:
		if is_on_floor():
			set_state(PlayerState.WALKING)
	if state == PlayerState.WALKING or state == PlayerState.SPRINTING:
		if Input.is_action_just_pressed("Jump"):
			set_state(PlayerState.AIRTIME)
			velocity.y = JUMP_FORCE
	if state == PlayerState.WALKING:
		if Input.is_action_pressed("Sprint"):
			set_state(PlayerState.SPRINTING)
	if state == PlayerState.SPRINTING:
		if not Input.is_action_pressed("Sprint"):
			set_state(PlayerState.WALKING)
		

				
				
func set_state(new_state:PlayerState) -> void:
	state = new_state
