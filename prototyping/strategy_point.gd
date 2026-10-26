extends Marker3D
class_name StrategyPoint

enum StrategyType {
	FULL_COVER,
	SHOOTING_COVER,
	SHOOTING_POINT,
}

@export var type:StrategyType
