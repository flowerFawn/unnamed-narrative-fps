extends Resource
class_name WeaponInfo
##Resource that holds static information about a weapon

enum WeaponType {
	MELEE,
	GUN,
}


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


##How an enemy will behave when using this weapon
@export_group("AI Behaviour")
##Distance an enemy will get within of the player before stopping while
##while simple positioning
@export var desired_shooting_distance:float
##Distance an enemy can be from the player while in simple shooting before
##repositioning
@export var maximum_comfortable_shooting_distance:float
##Distance an enemy must be from the player while in simple shooting without
##repositioning (if the player comes this close, they will walk away)
@export var minimum_comfortable_shooting_distance:float


##Technical parts of the weapon
@export_group("Technical")
##Type of weapon (relating to a class) that this weapon_info is for.
##This is used for creating a new instance of this weapon
@export var weapon_type:WeaponType


func create_instance() -> Weapon:
	var new_weapon_instance:Weapon
	match weapon_type:
		WeaponType.MELEE:
			new_weapon_instance = WeaponMelee.new()
		WeaponType.GUN:
			new_weapon_instance = WeaponGun.new()
	new_weapon_instance.weapon_info = self
	return new_weapon_instance
