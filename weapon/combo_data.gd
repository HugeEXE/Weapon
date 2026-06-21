extends Resource
class_name ComboData

@export var combo_name: String = "Default Combo"

# Requirements to unlock this combo matrix
@export var required_weapon_type: String = "" # e.g., "Rifle", "Glock", "Shotgun" (Leave blank for any)
@export var required_max_bounce: int = 0      # Minimum bullet bounces needed
@export var required_element: int = 0         # Required element (1: Flame, 2: Ice, 3: Electric, 4: Water)

# Stat modifications applied when active
@export var bonus_damage_multiplier: float = 1.0
@export var bonus_speed: float = 0.0
@export var custom_glow_color: Color = Color.WHITE
