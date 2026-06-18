extends Weapon
class_name SubmachineGun

@export var power_source: PowerSource

func _ready():
	weapon_name = "Uzi" # Force exact match string
	fire_rate = 0.1     # High-speed firing rate delay
	damage = 4
	sprite_path = "res://Sprite/Submachine - MP5A3 [80x48].png"
	apply_weapon_profile()

func fire():
	if not projectile_scene: return
	
	var bullet = projectile_scene.instantiate() as Projectile
	
	var muzzle = find_child("Muzzle")
	bullet.global_position = muzzle.global_position if muzzle else global_position
	bullet.rotation = global_rotation
	
	var element_coefficient = 1.0
	if power_source:
		element_coefficient = power_source.get_damage_coefficient()
		bullet.bullet_element = power_source.element
		bullet.bullet_color_override = power_source.get_element_color()
	
	# --- CRITICAL: GRAB COMBO AND PASS TO BULLET INSTANCE ---
	bullet.active_combo = ComboManager.get_active_combo(self)
	
	get_tree().root.add_child(bullet)
	
	bullet.current_damage = damage * damage_multiplier * get_current_damage_modifier() * element_coefficient
