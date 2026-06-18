extends Weapon
class_name Shotgun

@export var bullet_count: int = 9
@export var power_source: PowerSource

func _ready():
	weapon_name = "Shotgun"
	fire_rate = 1.2
	damage = 8
	sprite_path = "res://Sprite/[SHOOTING_CHAMBER_OPEN] Shotgun_V1.02.png"
	apply_weapon_profile()

func fire():
	if not projectile_scene:
		return

	# 1. Determine active combo and set total pellet count BEFORE running the loop
	var active_combo = ComboManager.get_active_combo(self)
	var final_pellet_count = bullet_count # Default to your base count (9)
	
	if active_combo == ComboManager.ComboID.SG_EXTRA_ROCK:
		final_pellet_count += 3 # Add 3 additional bullets for the Rock combo!

	# 2. Fire the calculated amount of pellets
	for i in range(final_pellet_count):
		var bullet = projectile_scene.instantiate() as Projectile
		
		# Set positions and muzzle location
		var muzzle = find_child("Muzzle")
		bullet.global_position = muzzle.global_position if muzzle else global_position
		
		# --- CHANGE SPREAD VALUE HERE ---
		# 0.45 radians gives a fantastic, wide sweeping crowd-control cone (~25° total angle deviation)
		var spread = 0.45 
		bullet.rotation = global_rotation + randf_range(-spread, spread)
		
		# 3. Read elemental properties out from power source if equipped
		var element_coefficient = 1.0
		if power_source:
			element_coefficient = power_source.get_damage_coefficient()
			bullet.bullet_element = power_source.element
			bullet.bullet_color_override = power_source.get_element_color()
			
		# Pass the combo signature down to the bullet
		bullet.active_combo = active_combo
		
		# 4. Spawn bullet into tree
		get_tree().root.add_child(bullet)
		
		# 5. Compute finalized combined damage matrix value
		bullet.current_damage = damage * damage_multiplier * get_current_damage_modifier() * element_coefficient
