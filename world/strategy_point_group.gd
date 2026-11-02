extends Node3D
class_name StrategyPointGroup



@export var level:Level


##3d raycast that can be moved around the scene to establish line of sight.
##When created and added is a child, is added as an internal child so not
##included in get_children.
var line_of_sight_raycast:RayCast3D

enum LineOfSightMode {
	REQUIRED,
	DISREGARDED,
	REQUIRED_NOT,
}

func _ready() -> void:
	setup()
	

func setup() -> void:
	line_of_sight_raycast = RayCast3D.new()
	add_child(line_of_sight_raycast, false, Node.INTERNAL_MODE_BACK)

##Returns the closest strategy point from a given global position (from).
func get_closest_point(from:Vector3, wanted_unoccupied:bool = true) -> StrategyPoint:
	var valid_point_found:bool = false
	var lowest_distance_squared:float = INF
	var current_distance_squared:float
	var closest_point:StrategyPoint
	for point:StrategyPoint in get_children():
		if wanted_unoccupied and point.occupied:
			continue #skips point before any calculations
			#only skips if looking for unoccupied points and this point is occupied
		current_distance_squared = from.distance_squared_to(point.global_position)
		if current_distance_squared < lowest_distance_squared:
			valid_point_found = true
			lowest_distance_squared = current_distance_squared
			closest_point = point
	if not valid_point_found:
		return null
	else:
		return closest_point
		
##Returns the closest strategy point from a given global position (from)
##that fits the given parameters. If values are 0, they will not be considered
func get_closest_point_parameters(from:Vector3,
	wanted_type:StrategyPoint.StrategyType, wanted_line_of_sight:LineOfSightMode = LineOfSightMode.DISREGARDED, wanted_unoccupied:bool = true):
	var valid_point_found:bool = false
	var lowest_distance_squared:float = INF
	var current_distance_squared:float
	var closest_point:StrategyPoint
	for point:StrategyPoint in get_children():
		if wanted_unoccupied and point.occupied:
			continue #skips to next point
		if wanted_type != StrategyPoint.StrategyType.ANY:
			if wanted_type != point.type:
				continue #skips to next point
		if wanted_line_of_sight != LineOfSightMode.DISREGARDED:
			var line_of_sight:bool = has_point_player_line_of_sight(point)
			if wanted_line_of_sight == LineOfSightMode.REQUIRED and not line_of_sight:
				continue
			elif wanted_line_of_sight == LineOfSightMode.REQUIRED_NOT and line_of_sight:
				continue
		
		current_distance_squared = from.distance_squared_to(point.global_position)
		if current_distance_squared < lowest_distance_squared:
			valid_point_found = true
			lowest_distance_squared = current_distance_squared
			closest_point = point
	if not valid_point_found:
		return null
	else:
		return closest_point
		
##Checks if there is a line of sight between the point and a player.
##Places a raycast at the point and sends it towards the player, and returns
##the opposite of if it is colliding
func has_point_player_line_of_sight(point:StrategyPoint) -> bool:
	#needs specific value not comparison, so can't be squared
	var distance_to_player:float
	var direction_to_player:Vector3
	line_of_sight_raycast.global_position = point.global_position
	distance_to_player = point.global_position.distance_to(level.player.global_position)
	direction_to_player = point.global_position.direction_to(level.player.global_position)
	line_of_sight_raycast.target_position = direction_to_player * distance_to_player
	line_of_sight_raycast.force_raycast_update()
	return not line_of_sight_raycast.is_colliding()
	
