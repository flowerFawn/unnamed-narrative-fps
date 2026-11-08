extends Head
class_name PlayerHead
##Handles player camera and weapons.
##Resets the basis and sets it based on the current yaw and pitch each time a mouse input is recieved.
##


##Amount to multiply relative mouse movement by
const SENSITIVITY:float = 0.001


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
##When a mouse motion is recieved, look around
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		take_look_input(event)
		
		
##When looking around, change the yaw and pitch based on the mouse input,
##Then reset the player's basis and set it again based on current yaw and pitch.
##rotated in yaw and then pitch (YX)
func take_look_input(mouse_motion:InputEventMouseMotion) -> void:
	yaw += -mouse_motion.screen_relative.x * SENSITIVITY
	pitch += -mouse_motion.screen_relative.y * SENSITIVITY
	update_look_direction()
