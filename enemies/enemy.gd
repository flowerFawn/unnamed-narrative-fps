extends Actor
class_name Enemy

var speed:float = 1.5
var current_hp:float



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

enum StrategyUse {
	NONE,
	START,
	FALLBACK,
	BOTH,
	FULL,
}

##How the enemy behaves
enum StrategyBehaviour {
	AMBUSH,
	CHASE,
}

enum ModeChangeContext {
	NA,
	START, ##search for any strategy point
	REPOSITION, ##search for nearby shooting point in line of sight
	RELOAD, ##search for cover out of line of sight, may be different to flee later
	RETREAT, ##search for a strategy point out of line of sight
	FLEE, ##search for cover out of line of sight
}

##Enemy type of this enemy
@export var enemy_type:EnemyType

@export_category("technical")
##The group of strategy points this enemy should use. Strategy points are
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
##Raycast pointed at the player to check for line of sight
@export var line_of_sight_raycast:RayCast3D
##Enemy head, controlling weapon use
@export var head:EnemyHead
##Mesh used to show the weapon the enemy is using
@export var weapon_mesh:MeshInstance3D
##Timer that is used for non-instant line of sight
@export var time_to_to_notice_timer:Timer
##Timer that is used for shot cooldowns of the enemy itself
@export var shot_cooldown_timer:Timer
##Timer used for updating the player's position
@export var player_position_update_timer:Timer

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
var has_line_of_sight:bool = false
##Distance from the player, squared to save costs
var distance_squared_to_player:float
##Global position of the player at the last frame the enemy had line of sight
##of the player
var last_known_player_position:Vector3 = Vector3.INF


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
##If the enemy is currently unable to shoot due to it's own cooldown
var is_on_shot_cooldown:bool = false

func _ready() -> void:
	setup()
	
func setup() -> void:
	current_hp = enemy_type.max_hp
	speed = enemy_type.speed
	time_to_to_notice_timer.wait_time = enemy_type.time_to_notice
	if enemy_type.shot_cooldown > 0:
		shot_cooldown_timer.wait_time = enemy_type.shot_cooldown
	player_position_update_timer.wait_time = enemy_type.player_location_update_rate
	
	weapon = enemy_type.weapon_type.create_instance()
	weapon.target_layer = 2 #targets player
	weapon_mesh.mesh = weapon.weapon_info.mesh
	desired_shooting_distance_squared = weapon.weapon_info.desired_shooting_distance ** 2
	maximum_comfortable_distance_squared = weapon.weapon_info.maximum_comfortable_shooting_distance ** 2
	minimum_comfortable_distance_squared = weapon.weapon_info.minimum_comfortable_shooting_distance ** 2
	head.add_child(weapon)
	weapon.reload_started.connect(mode_change_trigger_reload_started)
	weapon.reload_finished.connect(mode_change_trigger_reload_finished)
	match enemy_type.strategy_use:
		StrategyUse.NONE, StrategyUse.FALLBACK:
			set_mode(EnemyMode.SIMPLE_POSITIONING)
		StrategyUse.START, StrategyUse.BOTH, StrategyUse.FULL:
			set_mode(EnemyMode.STRATEGIC_POSITIONING)

func _process(delta: float) -> void:
	$Label3D.text = StrategyUse.keys()[enemy_type.strategy_use] + ", " + \
	EnemyMode.keys()[mode] + ", " + EnemyState.keys()[state] + ", " + \
	StrategyBehaviour.keys()[enemy_type.enemy_behaviour]

#region BEHAVIOUR

func _physics_process(delta: float) -> void:
	gather_info()
	check_for_mode_change_triggers()
	check_for_state_change()
	head.look_towards(last_known_player_position)
	if is_shooting:
		do_shooting()
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
	velocity *= speed
	if not is_on_floor():
		velocity.y = -level.GRAVITY

	
func shooting_physics_process(delta:float) -> void:
	velocity = Vector3.ZERO
	
	
func idle_physics_process(delta:float) -> void:
	velocity = Vector3.ZERO
	
	
	##Updates the goal point and sets that as the target position for the pathfinding agent
	##new goal point is dependent on mode and other factors
func update_pathfinding() -> void:
	match mode:
		EnemyMode.SIMPLE_POSITIONING:
			if not has_line_of_sight:
				return
			if desired_shooting_distance_squared < distance_squared_to_player:
				goal_point = last_known_player_position
			elif distance_squared_to_player < minimum_comfortable_distance_squared:
				var direction_from_player_to_enemy:Vector3
				direction_from_player_to_enemy = level.player.global_position.direction_to(global_position)
				direction_from_player_to_enemy = direction_from_player_to_enemy * sqrt(desired_shooting_distance_squared)
				goal_point = level.player.global_position + direction_from_player_to_enemy
		EnemyMode.SIMPLE_SEARCHING:
			goal_point = last_known_player_position
		EnemyMode.STRATEGIC_POSITIONING:
			goal_point = goal_strategy_point.global_position
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
func check_for_mode_change_triggers() -> void:
	match mode:
		EnemyMode.SIMPLE_POSITIONING:
			if distance_squared_to_player < desired_shooting_distance_squared and minimum_comfortable_distance_squared < distance_squared_to_player:
				mode_change_trigger_desired_distance()
			if not has_line_of_sight:
				mode_change_trigger_lost_player()
		EnemyMode.SIMPLE_SEARCHING:
			if has_line_of_sight:
				mode_change_trigger_found_player()
		EnemyMode.SIMPLE_SHOOTING, EnemyMode.STRATEGIC_SHOOTING:
			if not has_line_of_sight:
				mode_change_trigger_lost_player()
			elif maximum_comfortable_distance_squared < distance_squared_to_player:
				mode_change_trigger_player_leaves_range()
			elif distance_squared_to_player < minimum_comfortable_distance_squared:
				mode_change_trigger_player_moves_too_close()

		
			
##updates variables the enemy uses to determine behaviour
func gather_info() -> void:
	update_line_of_sight()
	update_player_distance()
	
##updates the line of sight raycast and if the enemy has line of sight.
##Only actually starts the time to notice timer
func update_line_of_sight() -> void:
	line_of_sight_raycast.target_position = level.player.global_position - global_position
	if distance_squared_to_player < enemy_type.sight_distance ** 2:
		if line_of_sight_raycast.is_colliding():
			time_to_to_notice_timer.stop()
			has_line_of_sight = false
		elif time_to_to_notice_timer.is_stopped():
			time_to_to_notice_timer.start()
	else:
		has_line_of_sight = false
		
		
func time_to_notice_finished() -> void:
	if not line_of_sight_raycast.is_colliding():
		has_line_of_sight = true
		update_known_player_position()
	
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
func set_mode(new_mode:EnemyMode, context:ModeChangeContext = ModeChangeContext.NA) -> void:
	if (mode == EnemyMode.STRATEGIC_POSITIONING and new_mode != EnemyMode.STRATEGIC_SHOOTING) or mode == EnemyMode.STRATEGIC_SHOOTING: #before change
		goal_strategy_point.leave()
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
		EnemyMode.STRATEGIC_POSITIONING:
			is_pathfinding = true
			is_shooting = false
			match context:
				ModeChangeContext.NA, ModeChangeContext.START:
					goal_strategy_point = strategy_points.get_closest_point(global_position)
				ModeChangeContext.REPOSITION:
					goal_strategy_point = strategy_points.get_closest_point_parameters(
						last_known_player_position, StrategyPoint.StrategyType.SHOOTING_POINT, StrategyPointGroup.LineOfSightMode.REQUIRED)
				ModeChangeContext.RETREAT:
					goal_strategy_point = strategy_points.get_closest_point_parameters(
						global_position, StrategyPoint.StrategyType.ANY, StrategyPointGroup.LineOfSightMode.REQUIRED_NOT)
				ModeChangeContext.FLEE, ModeChangeContext.RELOAD:
					goal_strategy_point = strategy_points.get_closest_point_parameters(
						global_position, StrategyPoint.StrategyType.COVER, StrategyPointGroup.LineOfSightMode.REQUIRED_NOT)
			goal_strategy_point.occupy()
		EnemyMode.STRATEGIC_SHOOTING:
			is_pathfinding = false
			is_shooting = true
	update_pathfinding()
			
			
			
func mode_change_trigger_player_moves_too_close() -> void:
	print("player too close mode change")
	match enemy_type.strategy_use:
		StrategyUse.NONE, StrategyUse.START:
			set_mode(EnemyMode.SIMPLE_POSITIONING)
		StrategyUse.FALLBACK, StrategyUse.BOTH:
			set_mode(EnemyMode.STRATEGIC_POSITIONING, ModeChangeContext.RETREAT)
			
			
func mode_change_trigger_player_leaves_range() -> void:
	print("player too far mode change")
	match  enemy_type.strategy_use:
		StrategyUse.NONE, StrategyUse.START, StrategyUse.FALLBACK:
			match mode:
				EnemyMode.SIMPLE_SHOOTING:
					set_mode(EnemyMode.SIMPLE_SEARCHING)
				EnemyMode.STRATEGIC_SHOOTING:
					if enemy_type.enemy_behaviour == StrategyBehaviour.CHASE:
						set_mode(EnemyMode.STRATEGIC_POSITIONING, ModeChangeContext.REPOSITION)
		StrategyUse.BOTH, StrategyUse.FULL:
			match mode:
				EnemyMode.SIMPLE_SHOOTING:
					set_mode(EnemyMode.SIMPLE_SEARCHING)
				EnemyMode.STRATEGIC_SHOOTING:
					if enemy_type.enemy_behaviour == StrategyBehaviour.CHASE:
						set_mode(EnemyMode.STRATEGIC_POSITIONING, ModeChangeContext.REPOSITION)
			
			
func mode_change_trigger_desired_distance() -> void:
	print("player desired distance mode change")
	match enemy_type.strategy_use:
		StrategyUse.NONE, StrategyUse.START, StrategyUse.BOTH:
			set_mode(EnemyMode.SIMPLE_SHOOTING)
		_:
			return
			
			
func mode_change_trigger_lost_player() -> void:
	match enemy_type.strategy_use:
		StrategyUse.NONE, StrategyUse.START:
			match mode:
				EnemyMode.SIMPLE_POSITIONING, EnemyMode.SIMPLE_SHOOTING:
					set_mode(EnemyMode.SIMPLE_SEARCHING)
				EnemyMode.STRATEGIC_POSITIONING, EnemyMode.STRATEGIC_SHOOTING:
					if enemy_type.enemy_behaviour == StrategyBehaviour.CHASE:
						set_mode(EnemyMode.SIMPLE_SEARCHING)
		
		
		
func mode_change_trigger_found_player() -> void:
	print("player found mode change")
	match enemy_type.strategy_use:
		StrategyUse.NONE, StrategyUse.START, StrategyUse.BOTH:
			set_mode(EnemyMode.SIMPLE_POSITIONING)
		StrategyUse.FALLBACK, StrategyUse.FULL:
			set_mode(EnemyMode.STRATEGIC_POSITIONING, ModeChangeContext.REPOSITION)
		

func mode_change_trigger_target_reached() -> void:
	print("reached target mode change")
	match enemy_type.strategy_use:
		StrategyUse.START, StrategyUse.FALLBACK, StrategyUse.BOTH, StrategyUse.FULL:
			if mode == EnemyMode.STRATEGIC_POSITIONING:
				set_mode(EnemyMode.STRATEGIC_SHOOTING)
				
				
func mode_change_trigger_hp_dropped() -> void:
	print("hp drop mode change")
	match enemy_type.strategy_use:
		StrategyUse.FALLBACK, StrategyUse.BOTH, StrategyUse.FULL:
			set_mode(EnemyMode.STRATEGIC_POSITIONING, ModeChangeContext.FLEE)
		_:
			return
			
			
func mode_change_trigger_reload_started() -> void:
	print("reload started mode change")
	match enemy_type.strategy_use:
		StrategyUse.NONE, StrategyUse.START:
			set_mode(EnemyMode.SIMPLE_POSITIONING)
		StrategyUse.FALLBACK, StrategyUse.BOTH:
			set_mode(EnemyMode.STRATEGIC_POSITIONING, ModeChangeContext.RELOAD)
		StrategyUse.FULL:
			pass
	
	
func mode_change_trigger_reload_finished() -> void:
	print("reload finished mode change")
	match enemy_type.strategy_use:
		StrategyUse.NONE, StrategyUse.START:
			set_mode(EnemyMode.SIMPLE_SHOOTING)
		StrategyUse.FALLBACK, StrategyUse.BOTH:
			set_mode(EnemyMode.STRATEGIC_POSITIONING, ModeChangeContext.REPOSITION)
		StrategyUse.FULL:
			pass

#endregion

##If out of ammo, reload.
##Otherwise shoot if possible, and start enemy's own shot timer
func do_shooting() -> void:
	if weapon.current_ammo == 0:
		weapon.attempt_reload()
	if has_line_of_sight and not is_on_shot_cooldown:
		if weapon.attempt_shoot():
			shot_cooldown_timer.start()
			is_on_shot_cooldown = true
		
		
func shooting_cooldown_finished() -> void:
	is_on_shot_cooldown = false


func get_hit(damage:float) -> void:
	current_hp -= damage
	if current_hp <= enemy_type.retreat_hp:
		mode_change_trigger_hp_dropped()
	if current_hp <= 0:
		die()
		
		
func die() -> void:
	if goal_strategy_point != null:
		goal_strategy_point.leave()
	weapon.cleanup()
	queue_free()
