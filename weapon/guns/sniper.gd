extends Weapon
class_name Sniper

@export var has_aimbot: bool = true

func _ready():
	weapon_name = "Sniper"
	fire_rate = 1.5
	damage = 30
	sprite_path = "res://Sprite/[SNIPER_SHOOTING]_Sniper_rifle_[KAR98]_V1.00.png"
	apply_weapon_profile()
