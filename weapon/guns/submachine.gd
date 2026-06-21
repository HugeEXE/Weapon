extends Weapon
class_name SubmachineGun

func _ready():
	weapon_name = "uzi" # Force exact match string
	fire_rate = 0.1     # High-speed firing rate delay
	damage = 4
	sprite_path = "res://Sprite/Submachine - MP5A3 [80x48].png"
	apply_weapon_profile()
