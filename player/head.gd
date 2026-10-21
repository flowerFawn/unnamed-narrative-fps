extends Node3D
class_name PlayerHead

var yaw:float = 0 #rotated in y axis, looking left and right
var pitch:float = 0 #rotated in x axis, looking up and down

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		yaw += -event.screen_relative.x * 0.001
		pitch += -event.screen_relative.y * 0.001
		transform.basis = Basis()
		rotate_object_local(Vector3.UP, yaw)
		rotate_object_local(Vector3.RIGHT, pitch)
