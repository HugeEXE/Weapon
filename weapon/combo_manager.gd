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
	if not weapon or not Global.active_bullet_profile or not weapon.power_source:
		return ComboID.NONE
		
	var w_name = weapon.weapon_name.to_lower()
	var b_profile = Global.active_bullet_profile
	var element = weapon.power_source.element
	
	# --- SHOTGUN COMBOS ---
	if w_name == "shotgun":
		if b_profile.should_split and element == PowerSource.ElementType.ELECTRIC:
			return ComboID.SG_CHAIN_STUN
		if b_profile.knockback_force > 0 and element == PowerSource.ElementType.ROCK: # Assuming powerful has knockback or distinct name
			return ComboID.SG_EXTRA_ROCK
		if b_profile.max_bounce > 0 and element == PowerSource.ElementType.ICE:
			return ComboID.SG_ICE_TRAIL
			
	# --- SNIPER COMBOS ---
	elif w_name == "sniper":
		if b_profile.max_pierce > 1 and element == PowerSource.ElementType.ROCK:
			return ComboID.SNIPER_BIG_ROCK
		if b_profile.should_split and element == PowerSource.ElementType.FLAME:
			return ComboID.SNIPER_FULL_SPLIT
		if b_profile.knockback_force > 0 and element == PowerSource.ElementType.WATER:
			return ComboID.SNIPER_VAMP_WATER
			
	# --- UZI (SUBMACHINE) COMBOS ---
	elif w_name == "submachine" or w_name == "uzi":
		if b_profile.damage_received_multiplier > 1.0 and element == PowerSource.ElementType.ELECTRIC:
			return ComboID.UZI_SHRED_ELEC
		if b_profile.max_bounce > 0 and element == PowerSource.ElementType.FLAME:
			return ComboID.UZI_FIRE_TRAIL
		if b_profile.should_split and element == PowerSource.ElementType.ICE:
			return ComboID.UZI_FREEZE_STACK
			
	# --- RIFLE COMBOS ---
	elif w_name == "rifle":
		if b_profile.damage_received_multiplier > 1.0 and element == PowerSource.ElementType.ELECTRIC:
			return ComboID.RIFLE_HP_SHRED
		if b_profile.max_bounce > 0 and element == PowerSource.ElementType.ICE:
			return ComboID.RIFLE_BOUNCE_FREEZE
		if b_profile.max_pierce > 1 and element == PowerSource.ElementType.WATER:
			return ComboID.RIFLE_OVERHEAL
			
	# --- REVOLVER COMBOS ---
	elif w_name == "revolver":
		if b_profile.knockback_force > 0 and element == PowerSource.ElementType.ROCK:
			return ComboID.REV_EXECUTE
		if b_profile.damage_received_multiplier > 1.0 and element == PowerSource.ElementType.FLAME:
			return ComboID.REV_MELT
		if b_profile.max_pierce > 1 and element == PowerSource.ElementType.ICE:
			return ComboID.REV_PERMA_FREEZE
			
	return ComboID.NONE
