extends Weapon
class_name Rifle

func _ready():
	weapon_name = "Rifle"
	fire_rate = 0.08
	damage = 15
	sprite_path = "res://Sprite/AK 47 [96x48].png"
	apply_weapon_profile()
