extends Weapon
class_name Shotgun

@export var bullet_count: int = 9
@export var spread_angle: float = 25.0 # Total spread arc in degrees

func _ready():
	weapon_name = "shotgun"
	fire_rate = 1.2
	damage = 8
	sprite_path = "res://Sprite/[SHOOTING_CHAMBER_OPEN] Shotgun_V1.02.png"
	apply_weapon_profile()

# =========================================================
# 💥 SHOTGUN CUSTOM PELLET FIRE ENGINE
# =========================================================
func fire():
	if not bullet_scene:
		return

	# 1. Fetch dynamic setup parameters from your central manager
	var final_speed = LoadoutManager.active_bullet_profile.speed
	var final_color = LoadoutManager.get_bullet_render_color()
	var max_bounce = LoadoutManager.active_bullet_profile.max_bounce
	var should_split = LoadoutManager.active_bullet_profile.should_split
	var manager_damage_mult = LoadoutManager.active_bullet_profile.damage_multiplier

	# 2. Find muzzle position placement
	var muzzle = find_child("Muzzle")
	var spawn_pos = muzzle.global_position if muzzle else global_position

	# 3. Dynamic Pellet Calculation based on Combo State
	var final_pellet_count = bullet_count
	
	# --- ENUM COMBO CHECK: Shotgun + Rock (Fires 3 additional bullets) ---
	if LoadoutManager.active_combo == ComboManager.ComboID.SG_EXTRA_ROCK:
		final_pellet_count += 3

	# 4. Spread Pattern Generation Loop
	# Calculates an even arc distribution based on your spread angle parameter
	var start_angle = -spread_angle / 2.0
	var angle_step = spread_angle / max(1, final_pellet_count - 1)

	for i in range(final_pellet_count):
		var bullet = bullet_scene.instantiate() as Projectile
		if bullet:
			# --- 1. SET COMBO AND ELEMENT FIRST ---
			if LoadoutManager.active_power_source and "element" in LoadoutManager.active_power_source:
				bullet.bullet_element = LoadoutManager.active_power_source.element
			else:
				bullet.bullet_element = 0
				
			bullet.active_combo = LoadoutManager.active_combo
			
			# --- 2. RUN PRODUCING ARCHITECTURE ---
			if bullet.has_method("setup_projectile"):
				bullet.setup_projectile(final_speed, final_color, max_bounce, should_split)
				
			bullet.global_position = spawn_pos
			
			# Calculate unique offset rotation for this individual pellet in the arc
			var relative_rotation = deg_to_rad(start_angle + (i * angle_step))
			bullet.rotation = global_rotation + relative_rotation
			
			# Combine gun base damage with bullet profile multipliers
			bullet.current_damage = damage * manager_damage_mult * get_current_damage_modifier()
			
			# --- 3. ADD TO ACTIVE TREE LAST ---
			get_tree().root.add_child(bullet)
