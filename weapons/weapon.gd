extends Node3D
class_name Weapon
##Base class for all weapons. Contains weapon_info, which contains all unchanging
##information about the weapon, and attributes for values which will change at 
##runtime. To use this weapon, outside actors should call attempt_shot.


##Type of automatic shooting
##Manual:Currently same as semi
##Semi:Shoots once each time the trigger is pulled/mouse clicked
##Full:Shoots when the trigger is pulled and the weapon is not on cooldown
enum AutoMode {
	MANUAL,
	SEMI,
	FULL,
}


##WeaponInfo that contains information about the weapon.
##Everything stored here is constant, and determined by the specific weapon
@export var weapon_info:WeaponInfo


##Timer that is used for the cooldown between shots
var cooldown_timer:Timer


##If the weapon is currently on cooldown and cannot be used
var on_cooldown:bool = false


func _ready() -> void:
	cooldown_timer = create_cooldown_timer()
	add_child(cooldown_timer)
	setup()
	
	
##subroutine to be overwritten in subclasses, called in ready, for any
##specifically required setup
func setup() -> void:
	pass

##Checks if able to shoot, and if so, does shoot.
##After shooting calls _shot_end() to start the cooldown.
##This is what should always be called by outside actors.
func attempt_shoot() -> void:
	if not on_cooldown:
		_shoot()
		_shot_visuals()
		_shot_end()

##Subroutine that actually shoots. Can be overwritten in some weapon subclasses.
##Should not ever be called from outside of attempt_shoot()
func _shoot() -> void:
	pass
	
	
##Subroutine that handles visuals for the weapon. Overwritten by subclasses
func _shot_visuals() -> void:
	pass



##Marks the cooldown flag as true to prevent more shooting, and starts the timer
##to undo this.
func _shot_end() -> void:
	on_cooldown = true
	cooldown_timer.start()

##Marks the cooldown flag as false to allow new shooting. Called by cooldown
##timer when it finishes.
func end_cooldown() -> void:
	on_cooldown = false
	
func attempt_hit(target:PhysicsBody3D) -> void:
	if target.is_in_group(&"hitable"):
		if target.has_method(&"hit"):
			target.hit(weapon_info.damage)

##Creates and returns a cooldown timer with required values, and connects
func create_cooldown_timer() -> Timer:
	var new_timer:Timer = Timer.new()
	new_timer.one_shot = true
	new_timer.wait_time = weapon_info.cooldown
	new_timer.timeout.connect(end_cooldown)
	return new_timer
