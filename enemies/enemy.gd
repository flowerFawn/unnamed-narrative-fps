extends Actor
class_name Enemy

const SPEED:float = 1.5


##What the enemy has as its current goal
enum EnemyMode{
	SIMPLE_SHOOTING,
	SIMPLE_POSITIONING,
	SIMPLE_SEARCHING,
	STRATEGIC_SHOOTING,
	STRATEGIC_POSITIONING,
	RETREATING,
}
##What the enemy is currently actually doing
enum EnemyState {
	IDLE,
	SEARCHING,
	WALKING,
	SPRINTING,
	SHOOTING,
	COVERING,
	AIRTIME,
}


##The group of strategy points this enemy should use. Strategy points are
##marked points in a level which are valuable for a purpose marked in them
##such as cover or shooting positions. This group can be queried for information
##about these strategy points
@export var strategy_points:StrategyPointGroup
##The weapon type that this enemy uses
@export var weapon_type:WeaponInfo

@export_group("base")
##Pathfinding agent node used for this enemies pathfinding. Should always
##be the one in the enemy scene
@export var pathfinding_agent:NavigationAgent3D
##Raycast targeting slightly below the enemy. If the enemy is too high in the air
##the enemy will go into airtime. If this ray is still colliding, the enemy
##will fall down without going into airtime
@export var airtime_raycast:RayCast3D
##Raycast pointed at the player to check for line of sight
@export var line_of_sight_raycast:RayCast3D

##Reference to the weapon this enemy is using. Generated based on weapon type
##when the enemy is created
var weapon:Weapon


##State the enemy is currently in. What the enemy is currently doing
var state:EnemyState
##Mode the enemy is currently in. What the enemy has as it's goal currently
var mode:EnemyMode
##Kind of strategy point the enemy would like to be at (such as cover or
##shooting position)
var goal_strategy_type:StrategyPoint.StrategyType
##Specific strategy point the enemy wants to move towards
var goal_strategy_point:StrategyPoint
##Specific point in global space the enemy wants to move towards
var goal_point:Vector3

##If the enemy has unbroken line of sight to the player
var has_line_of_sight:bool
##Distance from the player, squared to save costs
var distance_squared_to_player:float
##Global position of the player at the last frame the enemy had line of sight
##of the player
var last_known_player_position:Vector3


##Desired shooting distance (from weapon.weapon_info) squared.
##This means the distance squared function can be used, saving a square root
##to save cycles. This is stored in a variable so it doesn't have to be recalculated
##each time. Assigned when the new weapon instance is created
var desired_shooting_distance_squared:float
##Maximum comfortable shooting distance (from weapon.weapon_info) squared.
##This means the distance squared function can be used, saving a square root
##to save cycles. This is stored in a variable so it doesn't have to be recalculated
##each time. Assigned when the new weapon instance is created
var maximum_comfortable_distance_squared:float
##Minimum comfortable shooting distance (from weapon.weapon_info) squared.
##This means the distance squared function can be used, saving a square root
##to save cycles. This is stored in a variable so it doesn't have to be recalculated
##each time. Assigned when the new weapon instance is created
var minimum_comfortable_distance_squared:float



##If the enemy is currently trying to pathfind to a new position,
##or is remaining stationary
var is_pathfinding:bool
##If the enemy is currently trying to shoot at/attack the player from their
##current position
var is_shooting:bool

func _ready() -> void:
	setup()
	
func setup() -> void:
	weapon = weapon_type.create_instance()
	desired_shooting_distance_squared = weapon.weapon_info.desired_shooting_distance ** 2
	maximum_comfortable_distance_squared = weapon.weapon_info.maximum_comfortable_shooting_distance ** 2
	minimum_comfortable_distance_squared = weapon.weapon_info.minimum_comfortable_shooting_distance ** 2
	
	set_state(EnemyState.WALKING)
	set_mode(EnemyMode.SIMPLE_POSITIONING)


func _physics_process(delta: float) -> void:
	gather_info()
	check_for_mode_change()
	check_for_state_change()
	update_pathfinding()
	print(EnemyState.keys()[state])
	print(EnemyMode.keys()[mode])
	match state:
		EnemyState.WALKING:
			moving_physics_process(delta)
		EnemyState.AIRTIME:
			airtime_physics_process(delta)
		EnemyState.SHOOTING:
			shooting_physics_process(delta)
		EnemyState.IDLE:
			idle_physics_process(delta)
	move_and_slide()
	
func moving_physics_process(delta:float) -> void:
	velocity = global_position.direction_to(pathfinding_agent.get_next_path_position())
	velocity *= SPEED
	if not is_on_floor():
		velocity.y = -level.GRAVITY

	
func shooting_physics_process(delta:float) -> void:
	velocity = Vector3.ZERO
	
	
func idle_physics_process(delta:float) -> void:
	velocity = Vector3.ZERO
	
	#TODO: make this happen less regularly to save needless cpu cycles
	##Updates the goal point and sets that as the target position for the pathfinding agent
	##new goal point is dependent on mode and other factors
func update_pathfinding() -> void:
	match mode:
		EnemyMode.SIMPLE_POSITIONING:
			if desired_shooting_distance_squared < distance_squared_to_player:
				goal_point = level.player.global_position
			elif distance_squared_to_player < minimum_comfortable_distance_squared:
				var direction_from_player_to_enemy:Vector3
				direction_from_player_to_enemy = level.player.global_position.direction_to(global_position)
				direction_from_player_to_enemy = direction_from_player_to_enemy * sqrt(desired_shooting_distance_squared)
				goal_point = level.player.global_position + direction_from_player_to_enemy
		EnemyMode.SIMPLE_SEARCHING:
			goal_point = last_known_player_position
	pathfinding_agent.target_position = goal_point
	
	
##Checks if the enemy needs to change state, and changes it if so
func check_for_state_change() -> void:
	if state != EnemyState.AIRTIME:
		if not airtime_raycast.is_colliding():
			set_state(EnemyState.AIRTIME)
	if state == EnemyState.AIRTIME:
		if is_on_floor():
			set_state(EnemyState.WALKING)
	if state == EnemyState.WALKING:
		if not is_pathfinding:
			if is_shooting:
				set_state(EnemyState.SHOOTING)
			else:
				set_state(EnemyState.IDLE)
	else: #not walking
		if is_pathfinding:
			set_state(EnemyState.WALKING)
	if state == EnemyState.SHOOTING:
		if not is_shooting:
			if is_pathfinding:
				set_state(EnemyState.SHOOTING)
			else:
				set_state(EnemyState.IDLE)
			
##checks if the enemy needs to change mode, and updates it if so
func check_for_mode_change() -> void:
	if mode == EnemyMode.SIMPLE_POSITIONING:
		if distance_squared_to_player < desired_shooting_distance_squared and minimum_comfortable_distance_squared < distance_squared_to_player:
			set_mode(EnemyMode.SIMPLE_SHOOTING)
		if not has_line_of_sight:
			set_mode(EnemyMode.SIMPLE_SEARCHING)
	if mode == EnemyMode.SIMPLE_SEARCHING:
		if has_line_of_sight:
			set_mode(EnemyMode.SIMPLE_POSITIONING)
	if mode == EnemyMode.SIMPLE_SHOOTING:
		if not has_line_of_sight:
			set_mode(EnemyMode.SIMPLE_SEARCHING)
		elif maximum_comfortable_distance_squared < distance_squared_to_player or distance_squared_to_player < minimum_comfortable_distance_squared:
			set_mode(EnemyMode.SIMPLE_POSITIONING)

		
			
##updates variables the enemy uses to determine behaviour
func gather_info() -> void:
	update_line_of_sight()
	update_player_distance()
	update_known_player_position()
	
##updates the line of sight raycast and if the enemy has line of sight
func update_line_of_sight() -> void:
	line_of_sight_raycast.target_position = level.player.global_position - global_position
	has_line_of_sight = not line_of_sight_raycast.is_colliding()
	
##updates the distance squared
func update_player_distance() -> void:
	distance_squared_to_player = global_position.distance_squared_to(level.player.global_position)
	
##updates the known position of the player only if the enemy has line of sight
func update_known_player_position() -> void:
	if has_line_of_sight:
		last_known_player_position = level.player.global_position
			
##sets the state
func set_state(new_state:EnemyState) -> void:
	state = new_state
	
##sets the state, as well as other variables that should be changed depending on the state
func set_mode(new_mode:EnemyMode) -> void:
	mode = new_mode
	match new_mode:
		EnemyMode.SIMPLE_SHOOTING:
			is_pathfinding = false
			is_shooting = true
		EnemyMode.SIMPLE_POSITIONING:
			is_pathfinding = true
			is_shooting = true
			goal_point = level.player.global_position
		EnemyMode.SIMPLE_SEARCHING:
			is_pathfinding = true
			is_shooting = false
			goal_point = last_known_player_position
			
			
