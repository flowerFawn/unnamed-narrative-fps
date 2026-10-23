extends Node3D
class_name PlayerHead

##Amount to multiply relative mouse movement by
const SENSITIVITY:float = 0.001

##Rotated in y axis, looking left and right
var yaw:float = 0
##Rotated in x axis, looking up and down
var pitch:float = 0 

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		update_look_position(event)
		
		
func update_look_position(mouse_motion:InputEventMouseMotion) -> void:
	yaw += -mouse_motion.screen_relative.x * SENSITIVITY
	pitch += -mouse_motion.screen_relative.y * SENSITIVITY
	transform.basis = Basis()
	rotate_object_local(Vector3.UP, yaw)
	rotate_object_local(Vector3.RIGHT, pitch)
