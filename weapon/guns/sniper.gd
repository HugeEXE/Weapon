extends Weapon
class_name Sniper

@export var has_aimbot: bool = true

@export var power_source: PowerSource

func _ready():
	weapon_name = "Sniper"
	fire_rate = 1.5
	damage = 30
	sprite_path = "res://Sprite/[SNIPER_SHOOTING]_Sniper_rifle_[KAR98]_V1.00.png"
	
	apply_weapon_profile()
func fire():
	if projectile_scene:
		var bullet = projectile_scene.instantiate()
		
		var muzzle = find_child("Muzzle")
		bullet.global_position = muzzle.global_position if muzzle else global_position
		
		bullet.rotation = global_rotation
		# 1. Read values from the power source if one is equipped
		var element_coefficient = 1.0
		if power_source:
			element_coefficient = power_source.get_damage_coefficient()
			bullet.bullet_element = power_source.element
			bullet.bullet_color_override = power_source.get_element_color()
			
			bullet.active_combo = ComboManager.get_active_combo(self)
		
		get_tree().root.add_child(bullet)
		
		# 2. Compute final damage using the element coefficient
		bullet.current_damage = damage * damage_multiplier * get_current_damage_modifier() * element_coefficient
