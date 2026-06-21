extends Weapon
class_name Revolver

func _ready():
	weapon_name = "Revolver"
	fire_rate = 1.7
	damage = 50
	sprite_path = "C:/Users/ngocb/OneDrive/Documents/weapon/Revolver - Colt 45 [64x32].png"
	apply_weapon_profile()
