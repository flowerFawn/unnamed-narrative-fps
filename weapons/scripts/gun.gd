extends Weapon
class_name WeaponGun


var bullet_trail_mesh:BoxMesh

func setup() -> void:
	var trail_material:StandardMaterial3D
	bullet_trail_mesh = BoxMesh.new()
	bullet_trail_mesh.size = Vector3(0.05, 0.05, weapon_info.range)
	trail_material = StandardMaterial3D.new()
	trail_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	trail_material.albedo_color = Color(1, 1, 1, 0.2)
	bullet_trail_mesh.material = trail_material

func _shoot() -> void:
	var ray:RayCast3D = RayCast3D.new()
	get_tree().root.add_child(ray)
	ray.global_position = global_position
	ray.target_position = -global_basis.z.normalized() * weapon_info.range
	ray.force_raycast_update()
	if ray.is_colliding():
		var target:PhysicsBody3D = ray.get_collider()
		attempt_hit(target)
	#ray.queue_free()

func _shot_visuals() -> void:
	var trail_instance:MeshInstance3D = MeshInstance3D.new()
	trail_instance.mesh = bullet_trail_mesh
	get_tree().root.add_child(trail_instance)
	trail_instance.global_position = global_position
	trail_instance.global_basis = global_basis
	trail_instance.global_position += -global_basis.z.normalized() * weapon_info.range / 2
	await get_tree().create_timer(0.5).timeout
	trail_instance.queue_free()
