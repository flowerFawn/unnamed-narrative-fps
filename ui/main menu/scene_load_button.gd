extends Button
class_name SceneLoadButton

@export var scene_to_load:PackedScene

func _ready() -> void:
	pressed.connect(load_scene)
	
	
func load_scene() -> void:
	get_tree().change_scene_to_packed(scene_to_load)
