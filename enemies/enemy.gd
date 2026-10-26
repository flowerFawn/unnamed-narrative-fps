extends Actor
class_name Enemy

const SPEED:float = 3

enum EnemyState {
	IDLE,
	SEARCHING,
	WALKING,
	SPRINTING,
	SHOOTING,
	COVERING,
	AIRTIME,
}


##The group ofstrategy points this enemy should use. Strategy points are
##marked points in a level which are valuable for a purpose marked in them
##such as cover or shooting positions. This group can be queried for information
##about these strategy points
@export var strategy_points:StrategyPointGroup

@export_group("base")
##Pathfinding agent node used for this enemies pathfinding. Should always
##be the one in the enemy scene
@export var pathfinding_agent:NavigationAgent3D
##Raycast targeting slightly below the enemy. If the enemy is too high in the air
##the enemy will go into airtime. If this ray is still colliding, the enemy
##will fall down without going into airtime
@export var airtime_raycast:RayCast3D


##State the enemy is currently in
var state:EnemyState
##Kind of strategy point the enemy would like to be at (such as cover or
##shooting position)
var goal_strategy_type:StrategyPoint.StrategyType
##Specific strategy point the enemy wants to move towards
var goal_strategy_point:StrategyPoint

func _ready() -> void:
	goal_strategy_point = strategy_points.get_children()[0]
	state = EnemyState.WALKING


func _physics_process(delta: float) -> void:
	check_for_state_change()
	match state:
		EnemyState.WALKING:
			moving_physics_process(delta)
		EnemyState.AIRTIME:
			airtime_physics_process(delta)
	move_and_slide()
	
func moving_physics_process(delta:float) -> void:
	pathfinding_agent.target_position = goal_strategy_point.global_position
	velocity = global_position.direction_to(pathfinding_agent.get_next_path_position())
	velocity *= SPEED
	if not is_on_floor():
		velocity.y = -level.GRAVITY

	

	
	
	
func check_for_state_change() -> void:
	if state != EnemyState.AIRTIME:
		if not airtime_raycast.is_colliding():
			set_state(EnemyState.AIRTIME)
	if state == EnemyState.AIRTIME:
		if is_on_floor():
			set_state(EnemyState.WALKING)
			
func set_state(new_state:EnemyState) -> void:
	state = new_state
	
		
