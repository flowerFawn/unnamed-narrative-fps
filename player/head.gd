extends Node3D
class_name PlayerHead
##Handles player camera and weapons.
##Resets the basis and sets it based on the current yaw and pitch each time a mouse input is recieved.
##


##Amount to multiply relative mouse movement by
const SENSITIVITY:float = 0.001

##Rotated in y axis, looking left and right
var yaw:float = 0
##Rotated in x axis, looking up and down
var pitch:float = 0 

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
##When a mouse motion is recieved, look around
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		update_look_position(event)
		
		
##When looking around, change the yaw and pitch based on the mouse input,
##Then reset the player's basis and set it again based on current yaw and pitch.
##rotated in yaw and then pitch (YX)
func update_look_position(mouse_motion:InputEventMouseMotion) -> void:
	yaw += -mouse_motion.screen_relative.x * SENSITIVITY
	pitch += -mouse_motion.screen_relative.y * SENSITIVITY
	transform.basis = Basis()
	rotate_object_local(Vector3.UP, yaw)
	rotate_object_local(Vector3.RIGHT, pitch)
