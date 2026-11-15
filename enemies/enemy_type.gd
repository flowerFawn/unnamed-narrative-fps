extends Resource
class_name EnemyType

@export_group("Stats")
##Maximum and starting hp of the enemy
@export var max_hp:int = 100
##Speed at which the enemy moves
@export var speed:float = 1.5




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
