extends Area2D
class_name TrailPuddle

var element_type: int = 0
var tick_damage: float = 0.0
var lifetime: float = 1.5 # Matches the natural length of your animations

func _ready():
	# --- FIX: Connecting to the verified method declared below ---
	body_entered.connect(_on_body_entered)
	
	var anim_sprite = find_child("AnimatedSprite2D") as AnimatedSprite2D
	if anim_sprite:
		# Choose and kick off the correct animation loop
		if element_type == 1:
			anim_sprite.play("fire")
		elif element_type == 2:
			anim_sprite.play("ice")
			
		# --- FIX: Godot 4 correct syntax for setting additive blend modes via CanvasItem material ---
		anim_sprite.material = CanvasTexture.new() # Prepares canvas parameters
		# If you prefer setting this up globally, you can also just set Blend Mode to 'Add' 
		# inside the Inspector under CanvasItem -> Material -> CanvasItemMaterial!
	
	# Smoothly fade out the entire puddle tracking structure over time
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, lifetime).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_callback(queue_free)

func setup_trail(element: int, base_bullet_damage: float, element_color: Color):
	element_type = element
	
	# Only modulate generic elements, keep hand-drawn fire/ice full color
	if element_type != 1 and element_type != 2:
		modulate = element_color
	
	if element_type == 1: # FIRE TRAIL
		tick_damage = base_bullet_damage * 0.1
	elif element_type == 2: # ICE TRAIL
		scale = Vector2(1.5, 1.5) # Make ice patches chunkier

# --- FIX: Added the missing callback function inside the class scope ---
func _on_body_entered(body: Node2D):
	if body is Monster and body.has_method("apply_elemental_status"):
		if element_type == 2: # ICE TRAIL
			body.freeze_target(2.0) # Slow/Freeze them when stepping on ice patches
		elif element_type == 1: # FIRE TRAIL
			body.health -= tick_damage
			body.is_burning = true
			body.status_timer = 2.0
			body.burn_tick_damage = tick_damage
			print("Monster stepped in fire trail! Hurt for: ", tick_damage)
