extends StaticBody3D
class_name PlaceholderTarget
##Placeholder for a target. Destroyed when hit by a weapon

##called when hit by a weapon. Destroys the target
func hit(damage) -> void:
	queue_free()
