extends Weapon
class_name WeaponGun

func _shoot() -> void:
	var ray:RayCast3D = RayCast3D.new()
	get_tree().root.add_child(ray)
	ray.global_position = global_position
	ray.target_position = -global_basis.z.normalized() * weapon_info.range
	ray.force_raycast_update()
	if ray.is_colliding():
		var target:PhysicsBody3D = ray.get_collider()
		attempt_hit(target)
	ray.queue_free()
