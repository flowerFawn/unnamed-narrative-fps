extends CharacterBody3D
class_name Enemy

const SPEED:float = 3

enum EnemyState {
	IDLE,
	SEARCHING,
	MOVING,
	SHOOTING,
	COVERING,
}

@export var level:Level
@export var strategy_points:StrategyPointGroup

@export_group("base")
@export var pathfinding_agent:NavigationAgent3D




var enemy_state:EnemyState
var goal_strategy_type:StrategyPoint.StrategyType
var goal_strategy_point:StrategyPoint

func _ready() -> void:
	goal_strategy_point = strategy_points.get_children()[0]


func _physics_process(delta: float) -> void:
	pathfinding_agent.target_position = goal_strategy_point.global_position
	velocity = global_position.direction_to(pathfinding_agent.get_next_path_position())
	velocity *= SPEED
	velocity.y = 0
	if not is_on_floor():
		velocity.y = -10
	move_and_slide()
