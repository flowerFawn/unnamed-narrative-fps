extends Resource
class_name WeaponInfo
##Resource that holds static information about a weapon


##Name of the weapon
@export var name:String
##Damage dealt by the weapon
@export var damage:int
##Minimum time after shooting before shooting again (in seconds)
@export var cooldown:float
##Distance the weapon can cover, generally the length of a ray (in metres)
@export var range:float
##Type of automatic shooting
##Manual:Currently same as semi
##Semi:Shoots once each time the trigger is pulled/mouse clicked
##Full:Shoots when the trigger is pulled and the weapon is not on cooldown
@export var auto_mode:Weapon.AutoMode
