extends Node3D
class_name Head

##Rotated in y axis, looking left and right
var yaw:float = 0
##Rotated in x axis, looking up and down
var pitch:float = 0 

##reset the player's basis and set it again based on current yaw and pitch.
##rotated in yaw and then pitch (YX)
func update_look_direction() -> void:
	transform.basis = Basis()
	rotate_object_local(Vector3.UP, yaw)
	rotate_object_local(Vector3.RIGHT, pitch)
