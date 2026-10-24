extends Node3D
class_name PlayerWeaponHandler
##Handles weapons for the player. This includes attempting to shoot from input,
##and keeping them as children to keep their position the same as the player's


##The index of the selected weapon, in the list of children
var selected_weapon_index:int:
	get:
		return selected_weapon_index
	set(value):
		selected_weapon_index = 0
		current_weapon = get_children()[selected_weapon_index]
##Reference to the currently selected weapon
var current_weapon:Weapon

func _ready() -> void:
	selected_weapon_index = 0

func _physics_process(delta: float) -> void:
	#if click is held down
	if Input.is_action_pressed("Shoot"):
		#attempt shoot if held down at all and full auto
		if current_weapon.weapon_info.auto_mode == Weapon.AutoMode.FULL:
			attempt_shoot()
		#attempt shoot if just pressed and semi auto
		elif Input.is_action_just_pressed("Shoot"):
			attempt_shoot()

##Calls to attempt a shot in the weapon. If the weapon is on cooldown, this will
##not shoot
func attempt_shoot() -> void:
	current_weapon.attempt_shoot()
