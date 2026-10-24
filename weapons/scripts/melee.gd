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
	shapecast.force_shapecast_update()
	var target:PhysicsBody3D = shapecast.get_collider(0)
	if shapecast.get_collider(0) != null:
		attempt_hit(target)
	shapecast.queue_free()
		
