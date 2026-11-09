class_name InspectionTool
extends RefCounted

static func use_monocle(item: ItemData, gazette: Dictionary) -> Dictionary:
	if not item:
		return {"error": "No item to inspect."}
	item.inspected_visual = true
	var gazette_bounty = gazette.get("stolen_bounty", {})
	var is_bounty_match = false
	if item.is_stolen and item.gazette_bounty_id != "" and item.gazette_bounty_id == gazette_bounty.get("bounty_id", ""):
		is_bounty_match = true
	elif item.is_stolen and item.stolen_victim != "" and item.stolen_victim == gazette_bounty.get("victim", ""):
		is_bounty_match = true

	var text = "Visual Inspection: " + item.visual_flaw + "\n"
	if is_bounty_match:
		text += "⚠️ HOT ITEM CONFIRMED! Matches today's Gazette stolen notice filed by " + item.stolen_victim + "!"
	elif item.is_stolen:
		text += "⚠️ SUSPICIOUS: Shows hallmarks stolen from the " + item.stolen_from_faction + " (" + item.stolen_victim + ")!"
	else:
		text += "✓ Clean provenance. No signs of serial filed runes or stolen crests."

	return {
		"tool": "monocle",
		"title": "Jeweler's Monocle",
		"result_text": text,
		"is_hot": item.is_stolen,
		"is_bounty_match": is_bounty_match,
		"sfx": "monocle"
	}

static func use_tuning_fork(item: ItemData) -> Dictionary:
	if not item:
		return {"error": "No item to inspect."}
	item.inspected_resonance = true
	var sfx = "fork_buzz"
	var text = "Resonance: " + item.tuning_resonance + "\n"
	if item.is_counterfeit:
		text += "❌ COUNTERFEIT DETECTED: The enchantment produces a sour, hollow dissonance. " + item.counterfeit_reason
		sfx = "fork_buzz"
	elif item.enchantment_name != "Mundane / Inert":
		text += "✨ AUTHENTIC WEAVE: Harmonious celestial pitch. Certified genuine " + item.enchantment_name + "!"
		sfx = "fork_chime"
	else:
		text += "⚪ MUNDANE: No magical aura or harmonic vibration."
		sfx = "scale_clunk"

	return {
		"tool": "tuning_fork",
		"title": "Mana-Tuning Fork",
		"result_text": text,
		"is_counterfeit": item.is_counterfeit,
		"enchantment": item.enchantment_name,
		"sfx": sfx
	}

static func use_litmus_salt(item: ItemData) -> Dictionary:
	if not item:
		return {"error": "No item to inspect."}
	item.inspected_curse = true
	var text = "Alchemical Reaction: " + item.smoke_reaction + "\n"
	var sfx = "smoke_clean"
	if item.is_cursed:
		text += "☠️ DORMANT CURSE DETECTED: " + item.curse_type + "!\n" + item.curse_description
		sfx = "smoke_curse"
	else:
		text += "🕊️ SANCTIFIED & SAFE: Neutral reaction. Item is completely free of spiritual malevolence."
		sfx = "smoke_clean"

	return {
		"tool": "litmus_salt",
		"title": "Litmus Salt & Holy Water",
		"result_text": text,
		"is_cursed": item.is_cursed,
		"curse_type": item.curse_type,
		"sfx": sfx
	}

static func use_balance_scale(item: ItemData) -> Dictionary:
	if not item:
		return {"error": "No item to inspect."}
	item.inspected_weight = true
	var text = "Mass Analysis:\n"
	text += "Expected Density Mass: " + str(item.expected_weight) + " kg\n"
	text += "Measured Counterweight: " + str(item.actual_weight) + " kg\n"
	text += "Reading: " + item.scale_result

	if item.disguised_material != "":
		text += "\n⚠️ MATERIAL FRAUD: " + item.disguised_material

	return {
		"tool": "balance_scale",
		"title": "Precision Balance Scale",
		"result_text": text,
		"expected_weight": item.expected_weight,
		"actual_weight": item.actual_weight,
		"is_weight_fraud": item.disguised_material != "",
		"sfx": "scale_clunk"
	}
