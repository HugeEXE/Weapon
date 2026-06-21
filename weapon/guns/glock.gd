extends Weapon
class_name Glock

func _ready():
	weapon_name = "Glock"
	fire_rate = 1.0
	damage = 10.0
	sprite_path = "res://Sprite/Glock - P80 [64x48].png"
	apply_weapon_profile()
