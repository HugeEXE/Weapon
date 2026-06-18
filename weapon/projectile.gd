extends Area2D
class_name Projectile

var active_combo: int = 0 # Maps to ComboManager.ComboID

var trail_scene = preload("res://trail_puddle.tscn")
var trail_spawn_cooldown: float = 0.06 # Spawns a trail point roughly every 4 pixels traveled
var trail_timer: float = 0.0

var bullet_element: int = 0
var bullet_color_override: Color = Color.WHITE

var base_speed: float = 700.0
var base_damage: float = 10.0

var speed: float
var current_damage: float

# Tracking counters loaded from our active resource profiles
var current_pierce_left: int = 1
var current_bounce_left: int = 0

# Split variables
var should_split: bool = false
var split_count: int = 6
var is_fragment: bool = false

# --- FIX: Declared at the class level so all functions can see it ---
var damage_received_multiplier: float = 1.0

# --- NEW TIMER VARIABLE ---
# How many seconds the bullet travels before splitting automatically
# 0.25 seconds is roughly equivalent to a short "tick" distance out from your gun muzzle
var split_fuse_timer: float = 0.25 

# Array to prevent double hits on the same enemy frame
var damaged_bodies: Array = []

func _ready():
	var current_profile = Global.active_bullet_profile as BulletData
	var render_sprite = find_child("BulletRender") as AnimatedSprite2D
	
	if current_profile:
		# restored profile initialization parameters
		speed = base_speed * current_profile.speed_modifier
		current_damage = base_damage * current_profile.damage_modifier
		current_pierce_left = current_profile.max_pierce
		current_bounce_left = current_profile.max_bounce
		damage_received_multiplier = current_profile.damage_received_multiplier
		
		# Load split data properties
		should_split = current_profile.should_split
		split_count = current_profile.split_count
		is_fragment = current_profile.is_fragment
		
		if render_sprite:
			if current_profile.bullet_animations:
				render_sprite.sprite_frames = current_profile.bullet_animations
			render_sprite.play(current_profile.animation_name)
			
			# --- FIX: If an elemental power source is active, override color. Otherwise use standard profile color.
			if bullet_element != 0: 
				render_sprite.modulate = bullet_color_override
			else:
				render_sprite.modulate = current_profile.bullet_color
			
		# If this is a mini-fragment, shrink its visual scale layout
		if is_fragment:
			scale = Vector2(0.5, 0.5) 
			speed *= 0.8 # Make fragments fly slightly slower
			
		# --- COMBO HOOK: SNIPER + PIERCE + ROCK ---
		# Make the base anti-material shell massive if this specific combo matches
		if active_combo == ComboManager.ComboID.SNIPER_BIG_ROCK and not is_fragment:
			scale = Vector2(2.5, 2.5)
			
	else:
		speed = base_speed
		current_damage = base_damage
		current_pierce_left = 1
		current_bounce_left = 0
		damage_received_multiplier = 1.0
		if render_sprite:
			render_sprite.modulate = bullet_color_override

func spawn_elemental_trail():
	if not trail_scene: return
	
	var puddle = trail_scene.instantiate() as TrailPuddle
	
	# Crucial: Drop it at global coordinates so it doesn't move with the bullet
	puddle.global_position = global_position
	
	# Determine element assignments explicitly to bypass fallback constraints
	var trail_element = 2 if active_combo == ComboManager.ComboID.SG_ICE_TRAIL else 1
	
	# Initialize variables and color structures
	puddle.setup_trail(trail_element, current_damage, bullet_color_override)
	
	# Add it to the root map layout structure so it draws underneath actors
	get_tree().root.add_child(puddle)
	
func _physics_process(delta):
	var movement_direction = Vector2.RIGHT.rotated(rotation)
	position += movement_direction * speed * delta
	
	# --- NEW FUSE COUNTDOWN SYSTEM ---
	if should_split and not is_fragment:
		split_fuse_timer -= delta
		if split_fuse_timer <= 0.0:
			shatter()
			queue_free() # Terminate main shell to pop fragments out
			return # Stop executing further code on this dead frame
	
	if current_bounce_left > 0:
		check_camera_border_bounce(movement_direction)
	if active_combo == ComboManager.ComboID.SG_ICE_TRAIL or active_combo == ComboManager.ComboID.UZI_FIRE_TRAIL:
		trail_timer -= delta
		if trail_timer <= 0.0:
			trail_timer = trail_spawn_cooldown
			spawn_elemental_trail()

# --- THE SPLIT SHATTER LOGIC ---
func shatter():
	if not should_split or is_fragment:
		return
		
	var angle_step = (PI * 2) / split_count
	var bullet_scene = load(scene_file_path)
	
	for i in range(split_count):
		var fragment = bullet_scene.instantiate() as Projectile
		
		# --- NEW: Pass down the combo matrix, elemental type, and color to the fragments! ---
		fragment.active_combo = active_combo
		fragment.bullet_element = bullet_element
		fragment.bullet_color_override = bullet_color_override
		
		# --- COMBO HOOK: SNIPER + SPLIT + FIRE ---
		# If our sniper cluster combo hits, bypass the 0.8x fragment damage multiplier math rule
		if active_combo == ComboManager.ComboID.SNIPER_FULL_SPLIT:
			fragment.base_damage = base_damage
			fragment.current_damage = current_damage
		
		get_tree().root.add_child(fragment)
		
		# Position the cluster right where the parent bullet died
		fragment.global_position = global_position
		fragment.rotation = i * angle_step
		
		# Force the new child bullet to act as a terminal fragment asset
		fragment.is_fragment = true 
		fragment.should_split = false

func check_camera_border_bounce(movement_direction: Vector2):
	var viewport_rect = get_viewport_rect()
	var camera = get_viewport().get_camera_2d()
	if camera:
		var cam_center = camera.global_position
		var view_size = viewport_rect.size * camera.zoom
		var left_bound = cam_center.x - (view_size.x / 2)
		var right_bound = cam_center.x + (view_size.x / 2)
		var top_bound = cam_center.y - (view_size.y / 2)
		var bottom_bound = cam_center.y + (view_size.y / 2)
		
		var bounced = false
		if global_position.x <= left_bound or global_position.x >= right_bound:
			rotation = Vector2(-movement_direction.x, movement_direction.y).angle()
			bounced = true
			global_position.x = clamp(global_position.x, left_bound + 5, right_bound - 5)
		if global_position.y <= top_bound or global_position.y >= bottom_bound:
			rotation = Vector2(movement_direction.x, -movement_direction.y).angle()
			bounced = true
			global_position.y = clamp(global_position.y, top_bound + 5, bottom_bound - 5)
		if bounced:
			current_bounce_left -= 1

func _on_body_entered(body):
	if body.has_method("take_damage"):
		if body in damaged_bodies:
			return
		damaged_bodies.append(body)
		
		# 1. Deal the elementally scaled impact damage first
		body.take_damage(current_damage)
		
		# 2. Apply Armor Breaker (Octagon) if active
		if damage_received_multiplier > 1.0 and body.has_method("apply_armor_break"):
			body.apply_armor_break(damage_received_multiplier) 
			
		# 3. Apply your Power Source Elemental Status Effect + Combo details to the monster!
		if body.has_method("apply_elemental_status"):
			body.apply_elemental_status(bullet_element, current_damage, active_combo, self)
		
		# 4. Handle what happens to the bullet physically right now:
		if current_pierce_left > 1:
			current_pierce_left -= 1
			return # Keep going straight if we have piercing points left
			
		elif current_bounce_left > 0:
			current_bounce_left -= 1
			var movement_direction = Vector2.RIGHT.rotated(rotation)
			var enemy_vector = (global_position - body.global_position).normalized()
			if abs(enemy_vector.x) > abs(enemy_vector.y):
				rotation = Vector2(-movement_direction.x, movement_direction.y).angle()
			else:
				rotation = Vector2(movement_direction.x, -movement_direction.y).angle()
			position += Vector2.RIGHT.rotated(rotation) * 20.0
			return # Bounced away safely, don't delete yet!
			
		else:
			# Normal bullet or out of buffs? Explode/shatter and disappear instantly!
			shatter()
			queue_free()
			
	# Case B: We hit a solid obstacle structure (Wall, Crate, Tiles)
	else:
		if current_bounce_left > 0:
			current_bounce_left -= 1
			var movement_direction = Vector2.RIGHT.rotated(rotation)
			var wall_vector = (global_position - body.global_position).normalized()
			if abs(wall_vector.x) > abs(wall_vector.y):
				rotation = Vector2(-movement_direction.x, movement_direction.y).angle()
			else:
				rotation = Vector2(movement_direction.x, -movement_direction.y).angle()
			position += Vector2.RIGHT.rotated(rotation) * 15.0
		else:
			shatter()
			queue_free()
