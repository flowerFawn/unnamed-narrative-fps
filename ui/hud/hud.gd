extends CanvasLayer
class_name HUD

##Reference to player
@export var player:Player
##Reference to player weaponhandler
@export var weapon_handler:PlayerWeaponHandler

@export_group("Internal")
##Label that displays hp
@export var hp_label:Label
##Label that shows ammo as x/y
@export var ammo_label:Label
##Colour rect that tints the screen red when dead
@export var death_tint:ColorRect

func _process(delta: float) -> void:
	update_hud()

func update_hud() -> void:
	hp_label.text = str(player.current_hp)
	ammo_label.text = str(weapon_handler.current_weapon_ammo) + "/" + str(weapon_handler.current_weapon_max_ammo)
	if player.current_hp <= 0:
		death_tint.visible = true
