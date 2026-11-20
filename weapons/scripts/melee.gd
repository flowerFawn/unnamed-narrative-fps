extends Weapon
class_name WeaponMelee

func _shoot() -> void:
	var shapecast:ShapeCast3D = ShapeCast3D.new()
	var shape:SphereShape3D = SphereShape3D.new()
	shape.radius = weapon_info.range
	shapecast.shape = shape
	get_tree().root.add_child(shapecast)
	shapecast.global_position = global_position
	shapecast.target_position = -global_basis.z.normalized() * weapon_info.range
	shapecast.set_collision_mask_value(target_layer, true)
	shapecast.force_shapecast_update()
	if shapecast.is_colliding():
		var target:PhysicsBody3D = shapecast.get_collider(0)
		attempt_hit(target)
	shapecast.queue_free()
		
