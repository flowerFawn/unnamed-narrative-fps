extends OmniLight3D
class_name CandleLight3D

##Base energy of the candle light
@export var base_energy:float = 1.0
##Speed transform (along x axis) of candle light flicker
@export var flicker_speed:float = 1
##Intensity transform (along y axis) of candle light flicker
@export var flicker_intensity:float = 1
##Time offset of candle light flicker, in milliseconds
@export var flicker_time_offset:float = 0

var time_elapsed:float = 0

func _process(delta: float) -> void:
	time_elapsed += delta
	var flicker:float = flicker_intensity * sin((time_elapsed * flicker_speed) + flicker_time_offset)
	light_energy = base_energy + flicker
