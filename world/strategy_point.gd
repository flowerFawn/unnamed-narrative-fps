extends Marker3D
class_name StrategyPoint

enum StrategyType {
	ANY,
	FULL_COVER,
	SHOOTING_COVER,
	SHOOTING_POINT,
}

@export var type:StrategyType

var occupied:bool = false

func occupy() -> void:
	occupied = true
	
func leave() -> void:
	occupied = false
