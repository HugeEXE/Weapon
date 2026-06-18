extends Node2D
class_name Weapon

@export var projectile_scene: PackedScene

# Properties that subclasses will read/write
var weapon_name: String = ""
var damage: int = 10
var damage_multiplier: float = 1.0

func get_current_damage_modifier() -> float:
	# If a power-up profile exists, use its damage modifier. Otherwise, default to 1.0
	if Global.active_bullet_profile:
		return Global.active_bullet_profile.damage_modifier
	return 1.0
var fire_rate: float = 0.2
var sprite_path: String = "" 

var fire_timer: float = 0.0

func _process(delta):
	var mouse_pos = get_global_mouse_position()
	look_at(get_global_mouse_position())
	if mouse_pos.x < global_position.x:
		scale.y = -1
	else:
		scale.y = 1
	if fire_timer > 0:
		fire_timer -= delta

	if fire_timer <= 0:
		fire()
		fire_timer = fire_rate 

func _unhandled_input(event):
	if Input.is_key_pressed(KEY_1):
		Global.active_bullet_profile = null
		print("Debug: Reset ammo back to default baseline!")
		
	if Input.is_key_pressed(KEY_2):
		Global.active_bullet_profile = load("res://piercing_bullet.tres")
		print("Debug: Loaded Animated Piercing Bullets!")
		
	if Input.is_key_pressed(KEY_3):
		Global.active_bullet_profile = load("res://bouncing_bullet.tres")
		print("Debug: Loaded Bouncing Bullets!")
		
	# --- ADD THIS HOTKEY FOR SPLITTING SHOTGUNS ---
	if Input.is_key_pressed(KEY_4):
		var split_profile = load("res://split_bullet.tres")
		if split_profile:
			Global.active_bullet_profile = split_profile
			print("Debug: Loaded Cluster Split Bullets!")
		else:
			print("Debug ERROR: Could not find res://split_bullet.tres - Check path!")
	if Input.is_key_pressed(KEY_5):
		var heavy_profile = load("res://powerful_bullet.tres")
		if heavy_profile:
			Global.active_bullet_profile = heavy_profile
			print("Debug: Loaded High-Impact Powerful Bullets!")
		else:
			print("Debug ERROR: Could not find res://powerful_bullet.tres - Check path!")
	# Inside weapon.gd -> _unhandled_input(event)
	if Input.is_key_pressed(KEY_6):
		var break_profile = load("res://armor_breaker.tres")
		if break_profile:
			Global.active_bullet_profile = break_profile
			print("Debug: Loaded Armor Breaker Rounds!")
		else:
			print("Debug ERROR: Could not find res://armor_breaker.tres - Check path!")
		
# Dedicated function to update visuals safely
func apply_weapon_profile():
	var sprite_node = find_child("WeaponSprite") as Sprite2D
	if sprite_node and sprite_path != "":
		sprite_node.texture = load(sprite_path)
	
	fire_timer = fire_rate

func fire():
	pass
