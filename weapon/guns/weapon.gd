extends Node2D
class_name Weapon

# Define these here so Glock, Rifle, and Revolver can use them!
var weapon_name: String = ""
var fire_rate: float = 1.0
var damage: float = 10.0
var sprite_path: String = ""

@export var bullet_scene: PackedScene = preload("res://projectile.tscn")

# Add a placeholder function if your guns call apply_weapon_profile()
func apply_weapon_profile():
	# If you have a Sprite2D node on the gun, update its texture here
	var sprite = find_child("Sprite2D") or find_child("Sprite")
	if sprite and "texture" in sprite and sprite_path != "":
		sprite.texture = load(sprite_path)

func get_current_damage_modifier() -> float:
	# Default fallback to 1.0 so it doesn't change your base math results
	return 1.0

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

	# 3. Instantiate the Projectile
	var bullet = bullet_scene.instantiate() as Projectile
	if bullet:
		# --- 1. SET COMBO AND ELEMENT FIRST ---
		# Hand these over immediately so they are available for initialization functions
		if LoadoutManager.active_power_source and "element" in LoadoutManager.active_power_source:
			bullet.bullet_element = LoadoutManager.active_power_source.element
		else:
			bullet.bullet_element = 0 # Neutral
			
		bullet.active_combo = LoadoutManager.active_combo
		
		# --- 2. RUN PRODUCING ARCHITECTURE ---
		# Pass down physical data rules to set up profile metrics
		if bullet.has_method("setup_projectile"):
			bullet.setup_projectile(final_speed, final_color, max_bounce, should_split)
			
		bullet.global_position = spawn_pos
		bullet.rotation = global_rotation
		
		# Combine gun damage with bullet profile damage multipliers
		bullet.current_damage = damage * manager_damage_mult * get_current_damage_modifier()
		
		# --- 3. ADD TO ACTIVE TREE LAST ---
		# Now that everything is fully baked in RAM, push to active tree safely
		get_tree().root.add_child(bullet)
