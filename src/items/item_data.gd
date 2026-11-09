class_name ItemData
extends Resource

@export var id: String = ""
@export var item_name: String = "Mysterious Relic"
@export var description: String = ""
@export var category: String = "relic" # weapon, armor, jewelry, grimoire, relic, curio, potion
@export var base_value: int = 150
@export var icon_key: String = "dagger" # dagger, sword, chalice, ring, tome, amulet, skull, potion

# Physical & Material properties
@export var true_material: String = "Iron"
@export var disguised_material: String = ""
@export var expected_weight: float = 2.5
@export var actual_weight: float = 2.5
@export var scale_result: String = "Balanced - Authentic Mass"

# Flags & Hidden Traits
@export var is_stolen: bool = false
@export var stolen_from_faction: String = "" # "Aristocracy", "Guild", "Inquisition", "Syndicate"
@export var stolen_victim: String = ""
@export var gazette_bounty_id: String = ""

@export var is_counterfeit: bool = false
@export var counterfeit_reason: String = ""
@export var enchantment_name: String = "None"
@export var tuning_resonance: String = "Dull Thud" # Harmonic Chime, Sour Dissonance, Dull Thud, Eerie Wail

@export var is_cursed: bool = false
@export var curse_type: String = "" # Vampiric Drain, Screaming Spirit, Blood-Bound Ghost, Necrotic Rot
@export var curse_description: String = ""
@export var smoke_reaction: String = "Clear White Mist" # Clear White Mist, Violet Venom Smoke, Whispering Demonic Flame

@export var visual_flaw: String = "Pristine - No Tampering"
@export var heat_value: int = 15
@export var quality_stars: int = 2

# Inspection Tracking
@export var inspected_visual: bool = false
@export var inspected_resonance: bool = false
@export var inspected_curse: bool = false
@export var inspected_weight: bool = false

# Current location in shop
@export var location: String = "inventory" # inventory, cellar, counter, display

func is_fully_inspected() -> bool:
	return inspected_visual and inspected_resonance and inspected_curse and inspected_weight

func get_inspection_count() -> int:
	var count = 0
	if inspected_visual: count += 1
	if inspected_resonance: count += 1
	if inspected_curse: count += 1
	if inspected_weight: count += 1
	return count

func get_estimated_value(market_multiplier: float = 1.0) -> int:
	var val = float(base_value)
	if is_counterfeit and inspected_resonance:
		val *= 0.25
	elif is_cursed and inspected_curse:
		val *= 0.50 # Harder to sell legally unless laundered
	elif is_stolen and inspected_visual:
		val *= 0.70 # Black market cut
	if quality_stars > 2:
		val *= (1.0 + (quality_stars - 2) * 0.3)
	return int(max(10, val * market_multiplier))

func serialize() -> Dictionary:
	return {
		"id": id,
		"item_name": item_name,
		"description": description,
		"category": category,
		"base_value": base_value,
		"icon_key": icon_key,
		"true_material": true_material,
		"disguised_material": disguised_material,
		"expected_weight": expected_weight,
		"actual_weight": actual_weight,
		"scale_result": scale_result,
		"is_stolen": is_stolen,
		"stolen_from_faction": stolen_from_faction,
		"stolen_victim": stolen_victim,
		"gazette_bounty_id": gazette_bounty_id,
		"is_counterfeit": is_counterfeit,
		"counterfeit_reason": counterfeit_reason,
		"enchantment_name": enchantment_name,
		"tuning_resonance": tuning_resonance,
		"is_cursed": is_cursed,
		"curse_type": curse_type,
		"curse_description": curse_description,
		"smoke_reaction": smoke_reaction,
		"visual_flaw": visual_flaw,
		"heat_value": heat_value,
		"quality_stars": quality_stars,
		"inspected_visual": inspected_visual,
		"inspected_resonance": inspected_resonance,
		"inspected_curse": inspected_curse,
		"inspected_weight": inspected_weight,
		"location": location
	}

static func deserialize(dict: Dictionary) -> ItemData:
	var item = ItemData.new()
	for k in dict:
		if k in item:
			item.set(k, dict[k])
	return item
