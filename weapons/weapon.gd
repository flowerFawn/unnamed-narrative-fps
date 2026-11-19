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
##Timer that is used for reloading
var reload_timer:Timer

##If the weapon is currently on cooldown and cannot be used
var on_cooldown:bool = false
##
var current_ammo:int


func _ready() -> void:
	if weapon_info.cooldown > 0:
		cooldown_timer = create_timer(weapon_info.cooldown, end_cooldown)
		add_child(cooldown_timer)
	if weapon_info.uses_ammo:
		reload_timer = create_timer(weapon_info.reload_time, _reload_finished)
		add_child(reload_timer)
	setup()
	
	
##subroutine to be overwritten in subclasses, called in ready, for any
##specifically required setup. Call super() for the basic parts at the
##end of any overwritten setup though
func setup() -> void:
	if weapon_info.uses_ammo:
		current_ammo = weapon_info.mag_size
	else:
		current_ammo = 1 
		#keep ammo always above 0 and never change it if not using ammo
	
	
##subroutine to be overwritten in subclasses, anything that should be done
##when the weapon/actor using it is being removed and freed from memory
func cleanup() -> void:
	pass

##Checks if able to shoot, and if so, does shoot.
##After shooting calls _shot_end() to start the cooldown.
##This is what should always be called by outside actors.
func attempt_shoot() -> bool:
	if not on_cooldown and current_ammo > 0:
		_shoot()
		_shot_visuals()
		_shot_end()
		return true
	else:
		return false

##Subroutine that actually shoots. Can be overwritten in some weapon subclasses.
##Should not ever be called from outside of attempt_shoot()
func _shoot() -> void:
	pass
	
	
##Subroutine that handles visuals for the weapon. Overwritten by subclasses
func _shot_visuals() -> void:
	pass
	

##If the weapon can start to be reloaded, starts the reload timer
func attempt_reload() -> void:
	if not weapon_info.uses_ammo:
		return
	#if not already reloading, and mag not full
	if reload_timer.is_stopped() and current_ammo != weapon_info.mag_size:
		_start_reload()
		
		
func _start_reload() -> void:
	current_ammo = 0
	reload_timer.start()

func _reload_finished() -> void:
	current_ammo = weapon_info.mag_size

##Creates a decal from the given packed scene at the given point in global space
##may be overwritten in some subclasses for more complex decals
func _decal_visual(point:Vector3, decal:PackedScene) -> void:
	var new_decal:Decal = decal.instantiate()
	get_tree().root.add_child(new_decal)
	new_decal.global_position = point


##Marks the cooldown flag as true to prevent more shooting, and starts the timer
##to undo this.
func _shot_end() -> void:
	if weapon_info.uses_ammo:
		current_ammo -= 1
	if weapon_info.cooldown > 0:
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

##Creates and returns a timer with required values, and connects to given function
func create_timer(given_wait:float, timeout_function:Callable) -> Timer:
	var new_timer:Timer = Timer.new()
	new_timer.one_shot = true
	new_timer.wait_time = given_wait
	new_timer.timeout.connect(timeout_function)
	return new_timer

	
	
