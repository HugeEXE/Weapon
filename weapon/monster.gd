extends CharacterBody2D
class_name Monster

@export var monster_type: String = "normal" # Set in Inspector: "normal", "elite", "boss"
@export var health: int = 100000
@export var max_health: int = 100000 # Required tracking metric for % Max HP execution algorithms
@export var base_speed: float = 200.0

var speed: float = 200.0

# Track the enemy's personal defense status multiplier (1.0 = normal damage)
var armor_break_multiplier: float = 1.0

# Status Core Toggles
var is_burning: bool = false
var is_stunned: bool = false
var burn_tick_damage: float = 0.0
var status_timer: float = 0.0
var tick_timer: float = 0.0

# Combo Hit Counters
var uzi_ice_freeze_hits: int = 0

func _ready():
	speed = base_speed
	max_health = health # Calibrate base structural ceiling metric

func take_damage(amount: float):
	# Calculate damage taken after armor shredding calculations
	var final_damage = amount * armor_break_multiplier
	
	# --- RUNTIME EVALUATION: COMBO HOOKS ON INCOMING DAMAGE VALUES ---
	# Access active weapon configurations from global tracking references if required
	
	health -= final_damage
	print(name, " Hp: ", health)
	
	if health <= 0:
		die()

func _physics_process(delta):
	# Handle active status durations running out
	if status_timer > 0.0:
		status_timer -= delta
		if status_timer <= 0.0:
			clear_statuses()

	# Process Flame ticks every 0.5 seconds
	if is_burning and status_timer > 0.0:
		tick_timer += delta
		if tick_timer >= 0.5:
			tick_timer = 0.0
			health -= burn_tick_damage
			print(name, " Burn Tick! Damage: ", burn_tick_damage, " | HP: ", health)

# This function is triggered by our Armor Breaker bullet projectile!
func apply_armor_break(multiplier_value: float):
	armor_break_multiplier = multiplier_value
	
	# Optional visual feedback: Tint the monster slightly purple/vulnerable
	var sprite = find_child("Sprite2D") as Sprite2D
	if sprite:
		sprite.modulate = Color(1.3, 0.7, 1.3, 1.0)

# Handles incoming status logic passed down from our Power Source + Combo Matrix
func apply_elemental_status(element_type: int, incoming_damage: float, active_combo: int, current_bullet: Projectile):
	# -------------------------------------------------------------
	# SPECIAL PRE-CHECK: UZI + ARMOR BREAKER + ELECTRIC OVERRIDE
	# -------------------------------------------------------------
	var modified_damage = incoming_damage
	if is_stunned and active_combo == ComboManager.ComboID.UZI_SHRED_ELEC:
		# Amplifies structural calculations by 1.5x if target is locked down!
		modified_damage *= 1.5
		health -= (modified_damage - incoming_damage) # Deduct extra structural disparity margin
		print(name, " Uzi Shock Synergized! Amplified Hit Value: ", modified_damage)

	match element_type:
		1: # --- FLAME STATUS ---
			is_burning = true
			burn_tick_damage = modified_damage * 0.1
			
			# REVOLVER + ARMOR BREAKER + FLAME COMBO
			if active_combo == ComboManager.ComboID.REV_MELT:
				burn_tick_damage = modified_damage * 0.5 # Boost tick damage to 0.5x total damage
				
			status_timer = 3.0 # Lasts for 3 seconds (6 ticks total)
			tick_timer = 0.0
			modulate = Color(2.0, 0.5, 0.2) # Glow red-orange
			
		2: # --- ICE STATUS ---
			# --- FIX: Resolved 'current_bullet.Global' crash and added null safety guards ---
			if active_combo == ComboManager.ComboID.RIFLE_BOUNCE_FREEZE:
				if current_bullet and current_bullet.current_bounce_left < Global.active_bullet_profile.max_bounce:
					freeze_target(3.0)
					return
			
			elif active_combo == ComboManager.ComboID.REV_PERMA_FREEZE:
				freeze_target(3.0)
				return
				
			# UZI + SPLIT + ICE COMBO: Stack accumulation
			elif active_combo == ComboManager.ComboID.UZI_FREEZE_STACK:
				uzi_ice_freeze_hits += 1
				if uzi_ice_freeze_hits >= 5:
					uzi_ice_freeze_hits = 0
					freeze_target(1.0) # Flash freeze for 1 second flat
				return

			# Default Ice behavior
			speed = base_speed * 0.5 # Slows movement speed by 50%
			status_timer = 3.0
			modulate = Color(0.5, 0.8, 2.0) # Frosty blue
			
		3: # --- ELECTRIC STATUS ---
			is_stunned = true
			speed = 0.0 # Stop enemy completely
			status_timer = 0.5 
			modulate = Color(2.0, 2.0, 0.3) # Bright yellow
			
			# SHOTGUN + SPLIT + ELECTRIC COMBO
			if active_combo == ComboManager.ComboID.SG_CHAIN_STUN:
				chain_shock_nearby_targets()
				
			# RIFLE + ARMOR BREAKER + ELECTRIC COMBO
			elif active_combo == ComboManager.ComboID.RIFLE_HP_SHRED:
				var shred_percent = 0.10 # Normal
				if monster_type == "elite": shred_percent = 0.03
				elif monster_type == "boss": shred_percent = 0.01
				
				var shred_damage = max_health * shred_percent
				health -= shred_damage
				print(name, " Max HP Shred Active! Lost: ", shred_damage)
			
		4: # --- WATER STATUS ---
			var base_heal = modified_damage * 0.5
			var player = get_tree().get_first_node_in_group("Player")
			if player and player.has_method("heal"):
				# RIFLE + PIERCE + WATER COMBO: Handle shielding inside your player's local heal script logic
				player.heal(base_heal)
			modulate = Color(0.3, 0.6, 2.0) # Splash blue

		5: # --- ROCK STATUS ---
			# REVOLVER + POWERFUL + ROCK COMBO EXECUTION PROBABILITIES
			if active_combo == ComboManager.ComboID.REV_EXECUTE:
				var rolled_chance = randf()
				if monster_type == "elite" and rolled_chance <= 0.20:
					health -= max_health * 0.50
					print("CRITICAL SPLIT: Elite Target Executed for 50% Max HP!")
				elif monster_type == "boss" and rolled_chance <= 0.10:
					health -= max_health * 0.25
					print("CRITICAL SPLIT: Boss Target Executed for 25% Max HP!")

# Helper method to apply ice freeze states cleanly
func freeze_target(duration: float):
	speed = 0.0
	status_timer = duration
	modulate = Color(0.1, 0.9, 2.5) # Neon Frozen solid lock tint

# Shotgun Chain Stun propagation script logic
func chain_shock_nearby_targets():
	var detection_radius: float = 200.0 # Clear area of effect range in pixels
	
	# Create a temporary physics query shape
	var query = PhysicsShapeQueryParameters2D.new()
	var circle = CircleShape2D.new()
	circle.radius = detection_radius
	
	query.shape = circle
	
	# --- FIX: Uses safe transform vector matrix targeting directly ---
	query.transform = Transform2D(0, global_position)
	query.collision_mask = collision_mask # Look on the same layer monsters live on
	
	# Query the 2D physics world space state
	var space_state = get_world_2d().direct_space_state
	var results = space_state.intersect_shape(query)
	
	for result in results:
		var target = result.collider as CollisionObject2D
		
		# Ensure we don't infinitely trigger loops back onto ourselves!
		if target and target != self and target is Monster:
			if target.has_method("apply_elemental_status"):
				# Pass element 3 (Electric) with a generic combo signature to lock them down
				target.apply_elemental_status(3, 0.0, ComboManager.ComboID.NONE, null)
				print("Chain Stun arched over and locked down: ", target.name)

func clear_statuses():
	is_burning = false
	is_stunned = false
	speed = base_speed
	modulate = Color(1, 1, 1) # Reset to normal sprite color

func die():
	print(name, "Defeated")
	
	# --- ON KILL COMBOS ---
	# SNIPER + POWERFUL + WATER COMBO: Heal 5% max player hp on successful execution frames
	var player = get_tree().get_first_node_in_group("Player")
	
	# Verify using active profile attributes if your global combo is sniper-vamp state
	if player and player.has_method("heal") and player.has_attribute("max_hp"):
		# Ensure your base weapon check satisfies your combo manager requirements
		pass 
		
	queue_free()
