extends Resource
class_name EnemyType

@export_group("Stats")
##Maximum and starting hp of the enemy
@export var max_hp:int = 100
##Speed at which the enemy moves
@export var speed:float = 1.5
##Time the enemy will wait between shots. Only matters if greater than
##weapon cooldown. Makes little sense when using an automatic weapon.
##Mostly so pistol can have no cooldown
@export var shot_cooldown:float = 0
##Time after seeing the player to gain line of sight
@export var time_to_notice:float = 0.2
##How commonly (in seconds) the enemy updates the players known position.
##This impacts where the enemy shoots, and so accuracy.
##Lower value (more common updates) for more accurate enemies.
##Higher value (less common updates) for less accurate enemies.
@export var player_location_update_rate:float = 0.05



@export_group("Settings")
##The weapon type that this enemy uses
@export var weapon_type:WeaponInfo
##Type of strategy this enemy uses
@export var strategy_use:Enemy.StrategyUse
##Type of behaviour this enemy uses
@export var enemy_behaviour:Enemy.StrategyBehaviour
##What hp value an enemy will attempt to retreat
@export var retreat_hp:float = 0
##How far the line of sight raycast for this enemy can be
@export var sight_distance:float = 30
