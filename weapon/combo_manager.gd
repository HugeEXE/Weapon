extends Node

enum ComboID {
	NONE,
	SG_CHAIN_STUN, SG_EXTRA_ROCK, SG_ICE_TRAIL,
	SNIPER_BIG_ROCK, SNIPER_FULL_SPLIT, SNIPER_VAMP_WATER,
	UZI_SHRED_ELEC, UZI_FIRE_TRAIL, UZI_FREEZE_STACK,
	RIFLE_HP_SHRED, RIFLE_BOUNCE_FREEZE, RIFLE_OVERHEAL,
	REV_EXECUTE, REV_MELT, REV_PERMA_FREEZE
}

func get_active_combo(weapon: Weapon) -> ComboID:
	# 1. Check central LoadoutManager profiles instead of local weapon/global configurations
	if not weapon or not LoadoutManager.active_bullet_profile:
		return ComboID.NONE
		
	var w_name = weapon.weapon_name.to_lower()
	var b_profile = LoadoutManager.active_bullet_profile
	
	# 2. Extract active element safely if a central power source is equipped
	var element = 0
	if LoadoutManager.active_power_source and "element" in LoadoutManager.active_power_source:
		element = LoadoutManager.active_power_source.element
	
	# =========================================================
	# 💥 SHOTGUN COMBOS
	# =========================================================
	if w_name == "shotgun":
		if b_profile.should_split and element == 3: # Electric
			return ComboID.SG_CHAIN_STUN
		if (b_profile.type_name.to_lower() == "powerful" or b_profile.animation_name.to_lower() == "diamond") and element == 5: # Rock
			return ComboID.SG_EXTRA_ROCK
		if b_profile.max_bounce > 0 and element == 2: # Ice
			return ComboID.SG_ICE_TRAIL
			
	# =========================================================
	# 🎯 SNIPER COMBOS
	# =========================================================
	elif w_name == "sniper":
		if "max_pierce" in b_profile and b_profile.max_pierce > 1 and element == 5: # Rock
			return ComboID.SNIPER_BIG_ROCK
		if b_profile.should_split and element == 1: # Flame
			return ComboID.SNIPER_FULL_SPLIT
		if (b_profile.type_name.to_lower() == "powerful" or b_profile.animation_name.to_lower() == "diamond") and element == 4: # Water
			return ComboID.SNIPER_VAMP_WATER
			
	# =========================================================
	# 🏎️ UZI (SUBMACHINE) COMBOS
	# =========================================================
	elif w_name == "submachine" or w_name == "uzi" or w_name == "SubmachineGun":
		if "damage_received_multiplier" in b_profile and b_profile.damage_received_multiplier > 1.0 and element == 3: # Electric
			return ComboID.UZI_SHRED_ELEC
		if b_profile.max_bounce > 0 and element == 1: # Flame (UZI_FIRE_TRAIL)
			return ComboID.UZI_FIRE_TRAIL
		if b_profile.should_split and element == 2: # Ice
			return ComboID.UZI_FREEZE_STACK
			
	# =========================================================
	# ☱ RIFLE COMBOS
	# =========================================================
	elif w_name == "rifle":
		if "damage_received_multiplier" in b_profile and b_profile.damage_received_multiplier > 1.0 and element == 3: # Electric
			return ComboID.RIFLE_HP_SHRED
		if b_profile.max_bounce > 0 and element == 2: # Ice
			return ComboID.RIFLE_BOUNCE_FREEZE
		if "max_pierce" in b_profile and b_profile.max_pierce > 1 and element == 4: # Water
			return ComboID.RIFLE_OVERHEAL
			
	# =========================================================
	# 🤠 REVOLVER COMBOS
	# =========================================================
	elif w_name == "revolver":
		if (b_profile.type_name.to_lower() == "powerful" or b_profile.animation_name.to_lower() == "diamond") and element == 5: # Rock
			return ComboID.REV_EXECUTE
		if "damage_received_multiplier" in b_profile and b_profile.damage_received_multiplier > 1.0 and element == 1: # Flame
			return ComboID.REV_MELT
		if "max_pierce" in b_profile and b_profile.max_pierce > 1 and element == 2: # Ice
			return ComboID.REV_PERMA_FREEZE
			
	# --- SAFETY NET FALLBACK ---
	return ComboID.NONE
