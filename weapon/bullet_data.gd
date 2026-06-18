extends Resource
class_name BulletData

@export var type_name: String = "Default"
@export var bullet_animations: SpriteFrames
@export var animation_name: String = "default"

@export var max_pierce: int = 1
@export var max_bounce: int = 0
@export var knockback_force: float = 0.0
# Split variables
@export var should_split: bool = false
@export var split_count: int = 6
@export var is_fragment: bool = false

# --- ADD THIS FOR THE ARMOR BREAKER ---
@export var damage_received_multiplier: float = 1.0 # 1.0 means normal damage

@export var damage_modifier: float = 1.0
@export var speed_modifier: float = 1.0
@export var bullet_color: Color = Color.WHITE
