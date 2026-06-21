extends Area2D
class_name Projectile

var active_combo: int = 0 # Maps to ComboManager.ComboID from LoadoutManager

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

# Personal defense status multiplier (1.0 = normal damage)
var damage_received_multiplier: float = 1.0

# --- UPDATED: 5-Second Fuse Countdown Tracker ---
var split_fuse_timer: float = 1.0 

# Array to prevent double hits on the same enemy frame
var damaged_bodies: Array = []

# =========================================================
# ⚙️ INITIALIZATION ENGINE
# =========================================================
func setup_projectile(p_speed: float, p_color: Color, p_bounce: int, p_split: bool):
	speed = p_speed
	bullet_color_override = p_color
	current_bounce_left = p_bounce
	should_split = p_split
	
	var current_profile = LoadoutManager.active_bullet_profile as BulletData
	if current_profile:
		current_damage = base_damage * current_profile.damage_multiplier
		current_pierce_left = current_profile.max_pierce
		damage_received_multiplier = current_profile.damage_received_multiplier
		split_count = current_profile.split_count
		is_fragment = current_profile.is_fragment

func _ready():
	# Connects the engine's physical collision detection hook straight to code
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

	var current_profile = LoadoutManager.active_bullet_profile as BulletData
	var render_sprite = find_child("BulletRender") as AnimatedSprite2D
	
	# Fallback initialization validation gate
	if speed == 0.0 and current_profile:
		speed = base_speed * current_profile.speed_modifier
		current_bounce_left = current_profile.max_bounce
		should_split = current_profile.should_split
		current_damage = base_damage * current_profile.damage_multiplier
		current_pierce_left = current_profile.max_pierce
		damage_received_multiplier = current_profile.damage_received_multiplier
		split_count = current_profile.split_count
		is_fragment = current_profile.is_fragment
	elif speed == 0.0:
		speed = base_speed
		current_damage = base_damage
		current_pierce_left = 1
		damage_received_multiplier = 1.0

	# Sprite rendering pipeline initialization
	if render_sprite and current_profile:
		if current_profile.bullet_animations:
			render_sprite.sprite_frames = current_profile.bullet_animations
		
		var target_anim = current_profile.animation_name
		if active_combo == ComboManager.ComboID.UZI_FIRE_TRAIL:
			target_anim = "shuriken"
		elif active_combo == ComboManager.ComboID.SG_ICE_TRAIL:
			target_anim = "shuriken"
			
		if render_sprite.sprite_frames.has_animation(target_anim):
			render_sprite.play(target_anim)
		else:
			render_sprite.play("default")
		
		if bullet_element != 0: 
			render_sprite.modulate = bullet_color_override
		else:
			render_sprite.modulate = current_profile.bullet_color
	elif render_sprite:
		render_sprite.modulate = bullet_color_override

	# Modify physics values depending on fragment state
	if is_fragment:
		scale = Vector2(0.5, 0.5) 
		speed *= 0.8
		
	# --- COMBO HOOK: SNIPER + PIERCE + ROCK ---
	if active_combo == ComboManager.ComboID.SNIPER_BIG_ROCK and not is_fragment:
		scale = Vector2(2.5, 2.5)

	# Setup custom scaling hooks for our projectile trail setups
	if not is_fragment:
		if active_combo == ComboManager.ComboID.SG_ICE_TRAIL:
			scale = Vector2(1.8, 1.8)
		elif active_combo == ComboManager.ComboID.UZI_FIRE_TRAIL:
			scale = Vector2(2.0, 2.0)

# =========================================================
# 🌊 ENVIRONMENTAL TRAIL GENERATOR
# =========================================================
func spawn_elemental_trail():
	if not trail_scene: 
		return
	
	var puddle = trail_scene.instantiate() as TrailPuddle
	puddle.global_position = global_position
	
	var trail_element = 2 if active_combo == ComboManager.ComboID.SG_ICE_TRAIL else 1
	puddle.setup_trail(trail_element, current_damage, bullet_color_override)
	
	get_tree().root.add_child(puddle)
	
# =========================================================
# 🔄 ENGINE PHYSICS LOOPS
# =========================================================
func _physics_process(delta):
	var movement_direction = Vector2.RIGHT.rotated(rotation)
	position += movement_direction * speed * delta
	
	# --- ADDED: 5-Second Fuse Automatic Splitting Trigger ---
	if should_split and not is_fragment:
		split_fuse_timer -= delta
		if split_fuse_timer <= 0.0:
			call_deferred("shatter")
			queue_free()
			return 
	
	if current_bounce_left > 0:
		check_camera_border_bounce(movement_direction)
		
	if active_combo == ComboManager.ComboID.SG_ICE_TRAIL or active_combo == ComboManager.ComboID.UZI_FIRE_TRAIL:
		trail_timer -= delta
		if trail_timer <= 0.0:
			trail_timer = trail_spawn_cooldown
			spawn_elemental_trail()

# =========================================================
# 💥 FRAGMENT SPLITTING ARCHITECTURE (Impact Star Burst)
# =========================================================
func shatter():
	if not should_split or is_fragment:
		return
		
	var angle_step = (PI * 2) / split_count
	var bullet_scene_path = scene_file_path
	if bullet_scene_path == "":
		bullet_scene_path = "res://projectile.tscn"
		
	var bullet_scene = load(bullet_scene_path)
	
	for i in range(split_count):
		var fragment = bullet_scene.instantiate() as Projectile
		
		fragment.active_combo = active_combo
		fragment.bullet_element = bullet_element
		fragment.bullet_color_override = bullet_color_override
		
		# --- COMBO HOOK: SNIPER + SPLIT + FIRE ---
		if active_combo == ComboManager.ComboID.SNIPER_FULL_SPLIT:
			fragment.base_damage = base_damage
			fragment.current_damage = current_damage
			
		fragment.setup_projectile(speed, bullet_color_override, 0, false)
		
		get_tree().root.add_child(fragment)
		
		fragment.global_position = global_position
		fragment.rotation = i * angle_step
		fragment.is_fragment = true 
		fragment.should_split = false

# =========================================================
# 🛡️ SCREEN BOUNDARY BOUNCING ENGINE
# =========================================================
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

# =========================================================
# 🎯 HIT DETECTION MATRIX
# =========================================================
func _on_body_entered(body):
	if body.has_method("take_damage"):
		if body in damaged_bodies:
			return
		damaged_bodies.append(body)
		
		body.take_damage(current_damage)
		
		if damage_received_multiplier > 1.0 and body.has_method("apply_armor_break"):
			body.apply_armor_break(damage_received_multiplier) 
			
		if body.has_method("apply_elemental_status"):
			body.apply_elemental_status(bullet_element, current_damage, active_combo, self)
		
		if current_pierce_left > 1:
			current_pierce_left -= 1
			return 
			
		elif current_bounce_left > 0:
			current_bounce_left -= 1
			var movement_direction = Vector2.RIGHT.rotated(rotation)
			var enemy_vector = (global_position - body.global_position).normalized()
			if abs(enemy_vector.x) > abs(enemy_vector.y):
				rotation = Vector2(-movement_direction.x, movement_direction.y).angle()
			else:
				rotation = Vector2(movement_direction.x, -movement_direction.y).angle()
			position += Vector2.RIGHT.rotated(rotation) * 20.0
			return 
			
		else:
			call_deferred("shatter")
			queue_free()
			
	# Handle solid structures/tilemap walls layout boundary collisions
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
			call_deferred("shatter")
			queue_free()
