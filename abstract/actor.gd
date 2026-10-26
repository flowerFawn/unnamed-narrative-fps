@abstract extends CharacterBody3D
class_name Actor

@abstract func check_for_state_change() -> void

@abstract func set_state(new_state) -> void

##The level the actor is currently in. Stores information such as gravity
##as well as a reference to the player
@export var level:Level


##If the actor is falling at a slower speed than terminal velocity, adds gravity
##Will never cause the actor to fall faster than terminal velocity
func airtime_physics_process(delta:float) -> void:
	if velocity.y > -level.TERMINAL_VELOCITY:
		velocity.y = max(-level.TERMINAL_VELOCITY, velocity.y - (level.GRAVITY * delta))
