extends Node

# Active Slot Trackers
var active_weapon_type: String = "Glock"
var active_bullet_profile: BulletData = null
var active_power_source: Resource = null 

# Combo Tracking State (Now explicitly tracks ComboManager.ComboID types)
var active_combo: int = 0

# Master lookup dictionaries for dynamic instantiation
var weapon_scenes: Dictionary = {
	"Glock": preload("res://guns/glock.tscn"),
	"Revolver": preload("res://guns/Revolver.tscn"),
	"Rifle": preload("res://guns/Rifle.tscn"),
	"Shotgun": preload("res://guns/shotgun.tscn"),
	"SubmachineGun": preload("res://guns/submachine.tscn"),
	"Sniper": preload("res://guns/sniper.tscn")
}

func _ready():
	active_bullet_profile = BulletData.new()
	active_bullet_profile.speed = 400.0
	active_bullet_profile.damage_multiplier = 1.0
	active_bullet_profile.max_bounce = 0
	active_bullet_profile.should_split = false

func swap_loadout(new_weapon: String = "", new_bullet: BulletData = null, new_power: Resource = null):
	var weapon_changed: bool = false
	
	if new_weapon != "" and weapon_scenes.has(new_weapon):
		active_weapon_type = new_weapon
		weapon_changed = true
		
	if new_bullet != null:
		active_bullet_profile = new_bullet
		
	if new_power != null:
		active_power_source = new_power
	elif new_weapon == "" and new_bullet == null:
		active_power_source = null

	# Recalculate combos right after modifications take place
	check_active_combos()

	if weapon_changed:
		notify_player_weapon_swap()

# Helper method to expose clean profile naming properties straight to your HUD/Console
func get_active_bullet_name() -> String:
	if not active_bullet_profile:
		return "Default"
	if active_bullet_profile.type_name != "":
		return active_bullet_profile.type_name
		
	# Fallback: Parse the physical file path name to extract clean text keys
	var path = active_bullet_profile.resource_path
	if path != "":
		var file_name = path.get_file().get_basename() # e.g. "piercing_bullet"
		return file_name.replace("_", " ").capitalize()
		
	if active_bullet_profile.animation_name != "":
		return active_bullet_profile.animation_name.capitalize()
		
	return "Default"

# =========================================================
# 🔀 UNIFIED COMBOMANAGER ROUTING PIPELINE
# =========================================================
func check_active_combos():
	# 1. Spawn a lightweight object in RAM to bypass script property dependency constraints
	var temp_weapon = Weapon.new()
	
	# --- FIXED: Naming Translation Map ---
	# If our internal tracker is "SubmachineGun", translate it to "uzi" so it perfectly
	# satisfies ComboManager's match conditions!
	if active_weapon_type == "SubmachineGun":
		temp_weapon.weapon_name = "uzi"
	else:
		temp_weapon.weapon_name = active_weapon_type
	
	# 2. Hand data properties down into the official ComboManager Autoload script logic
	if has_node("/root/ComboManager"):
		active_combo = ComboManager.get_active_combo(temp_weapon)
	else:
		active_combo = 0 # Baseline safety fallback
		print("Warning: ComboManager Autoload node could not be found in the current scene tree root!")

	if active_combo > 0:
		print("Combo State Triggered Enum ID: ", active_combo)
		
	# 3. Clean up the placeholder object container from RAM instantly
	temp_weapon.free()

func notify_player_weapon_swap():
	var container = get_tree().get_first_node_in_group("WeaponContainer")
	if container:
		for child in container.get_children():
			child.queue_free()
		var target_scene = weapon_scenes.get(active_weapon_type)
		if target_scene:
			container.add_child(target_scene.instantiate())

func instantiate_weapon_in_world():
	notify_player_weapon_swap()

func get_bullet_render_color() -> Color:
	if active_power_source and "element" in active_power_source:
		match active_power_source.element:
			1: return Color(2.5, 0.5, 0.2) # Flame Glow
			2: return Color(0.2, 0.8, 2.5) # Ice Frost
			3: return Color(2.5, 2.5, 0.2) # Electric Voltage
			4: return Color(0.3, 0.6, 2.5) # Water Splash
			5: return Color(1.5, 1.0, 0.5) # Rock Earth
	return Color(1.0, 1.0, 1.0)
