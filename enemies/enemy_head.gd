extends Head
class_name EnemyHead

##Class for the head of an enemy. Used to hold the pitch and yaw of an enemy's
##look direction and handle the weapon

##look at a point, usually the player's position, in global space
##uses fun trig
func look_towards(point:Vector3) -> void:
	var vertical_distance:float
	var horizontal_distance:float
	var x_dif:float = point.x - global_position.x
	var z_dif:float = point.z - global_position.z
	horizontal_distance = sqrt((x_dif ** 2) + (z_dif ** 2))
	vertical_distance = point.y - global_position.y
	pitch = -atan2(vertical_distance, horizontal_distance)
	yaw = atan2(x_dif, z_dif)
	update_look_direction()
	global_basis.z = -global_basis.z #makes them shoot the right way
