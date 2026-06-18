extends Area2D
class_name LootDrop

enum DropType { BULLET_PROFILE, POWER_SOURCE }

var current_drop_type: DropType
var reward_data: Resource # Stores either a BulletData resource or a PowerSource resource

# --- FIX: Using find_child() is safer and prevents timing/naming path mismatches ---
@onready var sprite: Sprite2D = find_child("Sprite2D") as Sprite2D

func _ready():
	body_entered.connect(_on_body_entered)
	
	# Small floating/bobbing juice effect when sitting on the ground
	if sprite:
		var tween = create_tween().set_loops()
		tween.tween_property(sprite, "position:y", -6.0, 0.6).set_trans(Tween.TRANS_SINE)
		tween.tween_property(sprite, "position:y", 0.0, 0.6).set_trans(Tween.TRANS_SINE)

# Configures what this drop item represents physically
func setup_drop(type: DropType, data_resource: Resource, texture: Texture2D, glow_color: Color):
	current_drop_type = type
	reward_data = data_resource
	
	# Apply visual presentation metrics
	modulate = glow_color
	
	# --- RUNTIME SAFETY GUARDS ---
	if sprite == null:
		print("LOOT DROP CRITICAL ERROR: Could not find a child node named 'Sprite2D' inside your loot_drop.tscn scene tree hierarchy!")
		return
		
	if texture == null:
		print("LOOT DROP WARNING: No texture was assigned in the Monster Inspector! Falling back to Godot Icon.")
		# Uses fallback project icon so the game doesn't crash if your inspector slot is empty
		sprite.texture = load("res://icon.svg") 
	else:
		sprite.texture = texture

func _on_body_entered(body: Node2D):
	# Assuming your player script class_name is Player
	if body.has_method("equip_loot"):
		# Pass the raw structural reward straight to the player container
		body.equip_loot(current_drop_type, reward_data)
		
		# Play a pickup effect/audio here if you want!
		if reward_data:
			print("Picked up loot: ", reward_data.resource_path.get_file())
		else:
			print("Picked up loot with missing resource file reference data.")
			
		queue_free()
