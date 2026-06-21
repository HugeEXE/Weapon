extends CharacterBody2D
class_name Player

@export var movement_speed: float = 300.0

@onready var weapon_slot: Marker2D = $WeaponSlot

# --- AUTO-SHOOT TRACKING METRICS ---
var shoot_cooldown_timer: float = 0.0
var active_weapon: Weapon = null

func _ready():
	# 1. Add this player instance to the global "Player" group 
	# so the LoadoutManager can find it instantly when swapping weapons.
	add_to_group("Player")
	
	# 2. Tell the LoadoutManager to spawn the starting weapon inside our hands
	if has_node("/root/LoadoutManager"):
		LoadoutManager.call_deferred("instantiate_weapon_in_world")

func _physics_process(delta: float):
	# Handle standard 8-way movement vectors
	handle_movement()
	
	# Make the player character (or weapon layout) face toward the crosshair pointer
	look_at_mouse()
	
	# --- FIX: Passed delta parameter down into the tracking logic ---
	handle_shooting(delta)

func handle_movement():
	# Pull movement axis strengths based on project input mappings
	var input_direction: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	# Apply velocity values and run engine slide vector calculations safely
	velocity = input_direction * movement_speed
	move_and_slide()

func look_at_mouse():
	# Rotates the entire player structure to face the mouse cursor globally.
	look_at(get_global_mouse_position())

func handle_shooting(delta: float):
	# 1. Constantly tick down the shooting cooldown timer every frame
	if shoot_cooldown_timer > 0.0:
		shoot_cooldown_timer -= delta

	# 2. Safely grab the weapon sitting inside your WeaponSlot node hierarchy
	if weapon_slot and weapon_slot.get_child_count() > 0:
		active_weapon = weapon_slot.get_child(0) as Weapon
	else:
		active_weapon = null

	# 3. If no weapon is equipped or the cooldown timer hasn't hit zero, wait
	if not active_weapon or shoot_cooldown_timer > 0.0:
		return

	# 4. INPUT-FREE AUTO FIRE TRIGGER
	# Fires immediately on frame readiness, resetting the weapon's custom fire rate delay!
	active_weapon.fire()
	shoot_cooldown_timer = active_weapon.fire_rate

func _unhandled_input(event: InputEvent):
	if not (event is InputEventKey and event.pressed): 
		return
		
	var changed: bool = false
	
	match event.keycode:
		KEY_1:
			LoadoutManager.swap_loadout("Glock")
			changed = true
		KEY_2:
			LoadoutManager.swap_loadout("SubmachineGun")
			changed = true
		KEY_3:
			LoadoutManager.swap_loadout("Rifle")
			changed = true
		KEY_4:
			LoadoutManager.swap_loadout("Shotgun")
			changed = true
		KEY_5:
			LoadoutManager.swap_loadout("Sniper")
			changed = true
		KEY_F1:
			LoadoutManager.swap_loadout("Revolver")
			changed = true
		KEY_6:
			var path = "res://bullet/piercing_bullet.tres"
			if FileAccess.file_exists(path):
				LoadoutManager.swap_loadout("", load(path) as BulletData)
				changed = true
		KEY_7:
			var path = "res://bullet/bouncing_bullet.tres"
			if FileAccess.file_exists(path):
				LoadoutManager.swap_loadout("", load(path) as BulletData)
				changed = true
		KEY_8:
			var path = "res://bullet/armor_breaker.tres"
			if FileAccess.file_exists(path):
				LoadoutManager.swap_loadout("", load(path) as BulletData)
				changed = true
		KEY_9:
			var path = "res://bullet/split_bullet.tres"
			if FileAccess.file_exists(path):
				LoadoutManager.swap_loadout("", load(path) as BulletData)
				changed = true
		KEY_0:
			var path = "res://bullet/powerful_bullet.tres"
			if FileAccess.file_exists(path):
				LoadoutManager.swap_loadout("", load(path) as BulletData)
				changed = true
		KEY_Q:
			var path = "res://power source/flame_source.tres"
			if FileAccess.file_exists(path):
				LoadoutManager.swap_loadout("", null, load(path))
				changed = true
		KEY_W:
			var path = "res://power source/ice_source.tres"
			if FileAccess.file_exists(path):
				LoadoutManager.swap_loadout("", null, load(path))
				changed = true
		KEY_E:
			var path = "res://power source/electric_source.tres"
			if FileAccess.file_exists(path):
				LoadoutManager.swap_loadout("", null, load(path))
				changed = true
		KEY_R:
			var path = "res://power source/water_source.tres"
			if FileAccess.file_exists(path):
				LoadoutManager.swap_loadout("", null, load(path))
				changed = true
		KEY_T:
			var path = "res://power source/rock_source.tres"
			if FileAccess.file_exists(path):
				LoadoutManager.swap_loadout("", null, load(path))
				changed = true
			
		KEY_BACKSPACE:
			LoadoutManager.swap_loadout("Glock", BulletData.new(), null)
			changed = true

	if changed:
		print_current_loadout()

# =========================================================
# 📊 LOADOUT CONSOLE PRINTER (Cleaned & Left-Aligned)
# =========================================================
func print_current_loadout():
	var w_name = LoadoutManager.active_weapon_type
	var b_name = LoadoutManager.get_active_bullet_name() # <-- FIXED: Pulls accurate path-parsed names!
		
	var p_name = "None"
	if LoadoutManager.active_power_source and "element" in LoadoutManager.active_power_source:
		match LoadoutManager.active_power_source.element:
			1: p_name = "Flame"
			2: p_name = "Ice"
			3: p_name = "Electric"
			4: p_name = "Water"
			5: p_name = "Rock"

	print("Weapon: ", w_name, " | Bullet: ", b_name, " | Power: ", p_name)
