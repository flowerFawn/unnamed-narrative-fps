extends Node3D
class_name MenuCameraOperator
##Node that swaps between cameras on a given timer.
##All children should be said cameras

##Time between swapping cameras
@export var swap_time:float = 5

func _ready() -> void:
	var swap_timer:Timer = Timer.new()
	swap_timer.wait_time = swap_time
	add_child(swap_timer, false, Node.INTERNAL_MODE_FRONT)
	swap_timer.timeout.connect(swap_camera)
	swap_timer.start()
	

func swap_camera() -> void:
	var cameras:Array[Camera3D]
	cameras.assign(get_children(false))
	var current_camera:Camera3D
	current_camera = cameras[randi_range(0, cameras.size() - 1)]
	current_camera.current = true
