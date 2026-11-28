extends Actor
class_name Player
##Root of the player scene. Handles primarily movement and collision.
##Has states for walking/sprinting, and airtime.
##Depending on the state runs a different process, and then calls move_and_slide().
##Contains a PlayerHead that controls the camera and shooting.

const BASE_SPEED:int = 4
const SPRINT_MULTIPLIER:float = 1.5
const CROUCH_MULTIPLIER:float = 0.5
const JUMP_VERTICAL_FORCE:float = 2.5
const JUMP_HORIZONTAL_MULTIPLIER:float = 1.2

const PLAYER_HEAD_STANDING_POSITION:Vector3 = Vector3(0, 0.75, 0)

const MAX_HP:int = 100

enum PlayerState{
	WALKING,
	SPRINTING,
	CROUCHING,
	AIRTIME,
	DISABLED,
}


##Head node of the player. Controls the camera and the players pitch/yaw.
@export var head:PlayerHead
##Collision used when the player is standing
@export var standing_collision:CollisionShape3D
##Collision used when the player is crouching
@export var crouching_collision:CollisionShape3D


##State of the player
var state:PlayerState
##current hp of the player
var current_hp:int = MAX_HP


func _physics_process(delta: float) -> void:
	#checks if state needs to change at the start of this frame
	check_for_state_change()
	#runs the process for the current state
	match state:
		PlayerState.WALKING:
			walking_physics_process(delta)
		PlayerState.SPRINTING:
			walking_physics_process(delta, SPRINT_MULTIPLIER)
		PlayerState.CROUCHING:
			walking_physics_process(delta, CROUCH_MULTIPLIER)
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
		elif Input.is_action_just_pressed("Crouch"):
			print("yes")
			set_state(PlayerState.CROUCHING)
	elif state == PlayerState.SPRINTING:
		if not Input.is_action_pressed("Sprint"):
			set_state(PlayerState.WALKING)
	elif state == PlayerState.CROUCHING:
		if not Input.is_action_pressed("Crouch"):
			set_state(PlayerState.WALKING)
		
##Sets the player's state to airtime 
func start_jump() -> void:
	set_state(PlayerState.AIRTIME)
	velocity.y = JUMP_VERTICAL_FORCE
	velocity.x *= JUMP_HORIZONTAL_MULTIPLIER
	velocity.z *= JUMP_HORIZONTAL_MULTIPLIER
	
	
func start_crouch() -> void:
	print("starting crouch")
	standing_collision.disabled = true
	crouching_collision.disabled = false
	head.position = Vector3.ZERO
	state = PlayerState.CROUCHING
	
	
func leave_crouch() -> void:
	standing_collision.disabled = false
	crouching_collision.disabled = true
	head.position = PLAYER_HEAD_STANDING_POSITION
	state = PlayerState.WALKING
	
				
##Sets the player's state to a new state
func set_state(new_state:PlayerState) -> void:
	if state == new_state:
		return
	match state: #checks previous state
		PlayerState.CROUCHING:
			leave_crouch()
	state = new_state
	match new_state:
		PlayerState.CROUCHING:
			start_crouch()
	

func get_hit(damage:float) -> void:
	current_hp -= damage
	if current_hp <= 0:
		die()
		
		
func get_healed(heal:float) -> void:
	current_hp += heal
	if current_hp > MAX_HP:
		current_hp = MAX_HP
		
		
##Placeholder death. sends player back to main menu
func die():
	print("owieeee")
	get_tree().change_scene_to_file("uid://bem0qmxigw1nq")
