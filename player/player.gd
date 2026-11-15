extends Actor
class_name Player
##Root of the player scene. Handles primarily movement and collision.
##Has states for walking/sprinting, and airtime.
##Depending on the state runs a different process, and then calls move_and_slide().
##Contains a PlayerHead that controls the camera and shooting.

const BASE_SPEED:int = 1
const SPRINT_MULTIPLIER:float = 2
const JUMP_VERTICAL_FORCE:float = 2.5
const JUMP_HORIZONTAL_MULTIPLIER:float = 2

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
	
	
##Based on the current state, checks for factors that would cause state to change
##If walking or sprinting, checks for the player triggering a jump
##If in airtime, checks for hitting the floor
func check_for_state_change() -> void:
	#if statement rather than match case to allow for sharing some triggers between states but not all
	if state == PlayerState.AIRTIME:
		if is_on_floor():
			set_state(PlayerState.WALKING)
	else:
		if not is_on_floor():
			set_state(PlayerState.AIRTIME)
	if state == PlayerState.WALKING or state == PlayerState.SPRINTING:
		if Input.is_action_just_pressed("Jump"):
			start_jump()
	if state == PlayerState.WALKING:
		if Input.is_action_pressed("Sprint"):
			set_state(PlayerState.SPRINTING)
	if state == PlayerState.SPRINTING:
		if not Input.is_action_pressed("Sprint"):
			set_state(PlayerState.WALKING)
		
##Sets the player's state to airtime 
func start_jump() -> void:
	set_state(PlayerState.AIRTIME)
	velocity.y = JUMP_VERTICAL_FORCE
	velocity.x *= JUMP_HORIZONTAL_MULTIPLIER
	velocity.z *= JUMP_HORIZONTAL_MULTIPLIER
				
##Sets the player's state to a new state
func set_state(new_state:PlayerState) -> void:
	state = new_state
