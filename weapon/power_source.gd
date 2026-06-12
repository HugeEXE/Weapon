extends Resource
class_name PowerSource

enum ElementType { NEUTRAL, FLAME, ICE, ELECTRIC, WATER, ROCK }

@export var source_name: String = "Neutral Core"
@export var element: ElementType = ElementType.NEUTRAL

# Returns the damage coefficient based on the element type
func get_damage_coefficient() -> float:
	match element:
		ElementType.NEUTRAL: return 1.0
		ElementType.FLAME:   return 1.0 
		ElementType.ICE:     return 0.9
		ElementType.ELECTRIC:return 0.95
		ElementType.WATER:    return 1.0
		ElementType.ROCK:     return 0.5 # 0.5x total damage
		_:                   return 1.0

# Returns modifications to fire rates/attack speed delays
func get_attack_speed_modifier() -> float:
	if element == ElementType.ROCK:
		return -0.2 # Changed to negative for a 20% attack speed penalty!
	return 0.0
func get_element_color() -> Color:
	match element:
		ElementType.NEUTRAL:  return Color.WHITE        # Plain/Normal
		ElementType.FLAME:    return Color(2.0, 0.6, 0.2) # Intense Glowing Orange
		ElementType.ICE:      return Color(0.4, 0.8, 2.5) # Frosty Neon Blue
		ElementType.ELECTRIC: return Color(2.5, 2.5, 0.3) # Volted Electric Yellow
		ElementType.WATER:    return Color(0.2, 0.5, 2.0) # Deep Ocean Blue
		ElementType.ROCK:     return Color(0.6, 0.45, 0.3) # Heavy Earthy Brown
		_:                    return Color.WHITE
