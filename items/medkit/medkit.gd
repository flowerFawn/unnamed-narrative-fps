extends Item
class_name ItemsMedkit

##Amount this medkit will heal for
@export var heal_value:int


func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		body.get_healed(heal_value)
	queue_free()
