class_name RelicGenerator
extends RefCounted

const ITEM_NAMES = {
	"weapon": [
		"Rift-Runner Dagger", "Executioner's Flamberge", "Cursed Kris of Gehenna", 
		"Sun-Forged Rapier", "Assassin's Stiletto", "Maw-Carver Claymore", 
		"Paladin's Gilded Longsword", "Shadow-Fang Falchion", "Blight-Edged Scythe"
	],
	"armor": [
		"Mythril Mail Hauberk", "Adamantine Chestplate", "Cloak of the Rift Prowler",
		"Inquisitor's Iron Pauldron", "Blood-Soaked Greaves", "Shield of the Solar Ward",
		"Corrupted Dragonscale Cuirass", "Gilded Buckler of House Sterling"
	],
	"jewelry": [
		"Signet Ring of Duke Aldous", "Amulet of Whispering Souls", "Sapphire of the High Prelate",
		"Tears of the Void Brooch", "Torque of the Goblin Kingpin", "Banded Onyx Ring of Haste",
		"Pendant of the Bleeding Sun", "Choker of the Abyssal Siren"
	],
	"grimoire": [
		"Grimoire of Forbidden Cinders", "Tome of Flesh Transmutation", "Codex of Void Invocations",
		"Novice Primer (Falsely Rebound)", "Heretic's Litany of Sin", "Dungeon Cartographer's Journal"
	],
	"relic": [
		"Goblet of Eternal Thirst", "Preserved Basilisk Eye", "Luminescent Orb of the Maw",
		"Urn of Saint Vesper", "Crown of the Fallen Inquisitor", "Petrified Demon Heart",
		"Mirror of False Reflections", "Reliquary of the Ash Cult"
	]
}

const MATERIALS = {
	"Iron": {"density": 1.0, "fake": false},
	"Steel": {"density": 1.05, "fake": false},
	"Mythril": {"density": 0.55, "fake": false},
	"Adamantine": {"density": 1.85, "fake": false},
	"True Silver": {"density": 1.35, "fake": false},
	"Pure Gold": {"density": 2.45, "fake": false},
	"Dragon Bone": {"density": 0.75, "fake": false}
}

const FAKE_MATERIALS = [
	{"disguise": "Pig Iron disguised with Silver Leaf", "true_mat": "Iron", "claimed_mat": "True Silver", "actual_density": 1.0, "claimed_density": 1.35},
	{"disguise": "Lead core encased in thin Gold foil", "true_mat": "Iron", "claimed_mat": "Pure Gold", "actual_density": 1.45, "claimed_density": 2.45},
	{"disguise": "Lacquered tin passed off as Mythril", "true_mat": "Iron", "claimed_mat": "Mythril", "actual_density": 0.95, "claimed_density": 0.55},
	{"disguise": "Coated clay claiming to be Adamantine", "true_mat": "Iron", "claimed_mat": "Adamantine", "actual_density": 0.8, "claimed_density": 1.85}
]

const ENCHANTMENTS_GENUINE = [
	"Flame Infusion +2", "Void Tear Enchantment", "Aegis of the Sun", 
	"Frostbite Weaver", "Shadow Step Ward", "Thunderstrike Rune"
]

const ENCHANTMENTS_FAKE = [
	"Fire-beetle grease smeared over cold steel",
	"Luminescent cave-moss resin glow",
	"Phosphor paint emitting faint temporary sparks",
	"Friction-heated brass sleeve"
]

const CURSE_TYPES = [
	{"name": "Vampiric Drain", "desc": "Subtly siphons the wielder's vitality during combat to feed an insatiable bloodlust."},
	{"name": "Screaming Spirit", "desc": "Harbors the frantic phantom of a murdered crusader that shrieks in total darkness."},
	{"name": "Blood-Bound Poltergeist", "desc": "Tied to the vengeance of an ancient family bloodline; violently rejects other masters."},
	{"name": "Necrotic Rot", "desc": "Exudes an invisible miasma that slowly withers nearby living tissue and spoiled grain."},
	{"name": "Greed Hex", "desc": "Induces paranoia and murderous possessiveness in anyone holding it for over three days."}
]

const FACTIONS = ["Aristocracy", "Guild", "Inquisition", "Syndicate"]

static func generate_random_relic(day: int = 1, force_bounty_item: Dictionary = {}) -> ItemData:
	var item = ItemData.new()
	var categories = ITEM_NAMES.keys()
	var category = categories[randi() % categories.size()]
	
	if not force_bounty_item.is_empty():
		item.id = force_bounty_item.get("id", "bounty_" + str(randi() % 10000))
		item.item_name = force_bounty_item.get("name", "Royal Heirloom")
		item.category = force_bounty_item.get("category", "jewelry")
		item.is_stolen = true
		item.stolen_from_faction = force_bounty_item.get("faction", "Aristocracy")
		item.stolen_victim = force_bounty_item.get("victim", "Duke Aldous")
		item.gazette_bounty_id = force_bounty_item.get("bounty_id", "BOUNTY-01")
		item.base_value = force_bounty_item.get("value", 850)
	else:
		item.id = "item_" + str(Time.get_ticks_msec()) + "_" + str(randi() % 9999)
		item.category = category
		var name_list = ITEM_NAMES[category]
		item.item_name = name_list[randi() % name_list.size()]
		item.base_value = int(randf_range(80, 400) + day * 15)

	# Assign icon key based on category & name
	var lower_name = item.item_name.to_lower()
	if "dagger" in lower_name or "stiletto" in lower_name or "kris" in lower_name:
		item.icon_key = "dagger"
	elif "sword" in lower_name or "flamberge" in lower_name or "claymore" in lower_name or "scythe" in lower_name:
		item.icon_key = "sword"
	elif "ring" in lower_name:
		item.icon_key = "ring"
	elif "amulet" in lower_name or "pendant" in lower_name or "choker" in lower_name or "brooch" in lower_name:
		item.icon_key = "amulet"
	elif "tome" in lower_name or "grimoire" in lower_name or "codex" in lower_name or "journal" in lower_name:
		item.icon_key = "tome"
	elif "goblet" in lower_name or "chalice" in lower_name or "urn" in lower_name:
		item.icon_key = "chalice"
	elif "eye" in lower_name or "heart" in lower_name or "orb" in lower_name:
		item.icon_key = "skull"
	else:
		item.icon_key = "dagger"

	# Stolen Status
	if not item.is_stolen:
		var stolen_chance = clampf(0.25 + day * 0.015, 0.25, 0.65)
		if randf() < stolen_chance:
			item.is_stolen = true
			item.stolen_from_faction = FACTIONS[randi() % FACTIONS.size()]
			item.stolen_victim = _get_random_victim(item.stolen_from_faction)
			item.heat_value += 20
			
	# Visual Flaws
	if item.is_stolen:
		var flaws = [
			"Serial runes chiseled off with crude rasp",
			"Dried blood caked in the crest indentations",
			"Mismatched maker's mark hammered over original seal",
			"Deep gouge attempting to erase the owner's monogram"
		]
		item.visual_flaw = flaws[randi() % flaws.size()]
	else:
		if randf() < 0.2:
			item.visual_flaw = "Minor battle scuffs; authentic artisan stamp intact"
		else:
			item.visual_flaw = "Pristine - Authentic artisan hallmark untouched"

	# Material & Scale Mass
	var is_fake_mat = randf() < 0.3
	var base_weight = randf_range(1.5, 6.0)
	if is_fake_mat and not item.is_stolen: # Don't stack too many fakes on one item constantly
		var fake_data = FAKE_MATERIALS[randi() % FAKE_MATERIALS.size()]
		item.disguised_material = fake_data["disguise"]
		item.true_material = fake_data["true_mat"]
		var claimed_mat = fake_data["claimed_mat"]
		var density_ratio = fake_data["actual_density"] / fake_data["claimed_density"]
		item.expected_weight = snappedf(base_weight, 0.1)
		item.actual_weight = snappedf(base_weight * density_ratio, 0.1)
		if abs(item.actual_weight - item.expected_weight) > 0.4:
			item.is_counterfeit = true
			item.counterfeit_reason = "Density mismatch: Claimed " + claimed_mat + ", but mass ratio is severely distorted."
			item.scale_result = "DISSONANT - Mass deviates sharply from " + claimed_mat + " standards!"
		else:
			item.scale_result = "Plausible Balance within standard tolerances."
	else:
		var mat_keys = MATERIALS.keys()
		item.true_material = mat_keys[randi() % mat_keys.size()]
		item.disguised_material = ""
		item.expected_weight = snappedf(base_weight, 0.1)
		item.actual_weight = item.expected_weight
		item.scale_result = "BALANCED - Exact match for authentic " + item.true_material + " density."

	# Enchantment & Tuning Fork Resonance
	var has_magic = randf() < 0.6
	if has_magic:
		var is_fake_magic = randf() < 0.4 or item.is_counterfeit
		if is_fake_magic:
			item.is_counterfeit = true
			var fake_ench = ENCHANTMENTS_FAKE[randi() % ENCHANTMENTS_FAKE.size()]
			item.enchantment_name = "Counterfeit Magic Glow"
			item.counterfeit_reason += " " + fake_ench
			item.tuning_resonance = "Sour Dissonance (Rattling fake buzz, no harmonic soul)"
		else:
			item.enchantment_name = ENCHANTMENTS_GENUINE[randi() % ENCHANTMENTS_GENUINE.size()]
			item.tuning_resonance = "Harmonic Chime (Pure, vibrating celestial resonance)"
			item.base_value = int(item.base_value * 1.5)
	else:
		item.enchantment_name = "Mundane / Inert"
		item.tuning_resonance = "Dull Thud (Mundane material, zero magical conduction)"

	# Curse & Litmus Salt
	var curse_chance = clampf(0.20 + day * 0.01, 0.20, 0.50)
	if randf() < curse_chance:
		item.is_cursed = true
		var curse = CURSE_TYPES[randi() % CURSE_TYPES.size()]
		item.curse_type = curse["name"]
		item.curse_description = curse["desc"]
		item.heat_value += 25
		item.smoke_reaction = "Violet Demonic Flame (Salt whispers in agonized tongues as purple miasma boils)"
	else:
		item.is_cursed = false
		item.curse_type = ""
		item.curse_description = "Free of spiritual taint or infernal pacts."
		item.smoke_reaction = "Clear Pure White Vapor (Inert; absolute absence of demonic taint)"

	# Star Rating
	if item.is_cursed or item.is_stolen or item.is_counterfeit:
		item.quality_stars = randi_range(2, 4)
	else:
		item.quality_stars = randi_range(1, 5)

	item.description = "A " + item.true_material + " " + item.category + ". "
	if item.enchantment_name != "Mundane / Inert":
		item.description += "Radiates " + item.enchantment_name + ". "
	if item.is_stolen:
		item.description += "Shows noticeable signs of illicit procurement. "

	return item

static func _get_random_victim(faction: String) -> String:
	match faction:
		"Aristocracy":
			var names = ["Duke Aldous Sterling", "Lady Vivienne de Claire", "Baron Montfort", "Countess Isolde"]
			return names[randi() % names.size()]
		"Inquisition":
			var names = ["Grand Inquisitor Tenebros", "Bishop Valerius", "Preceptor Malakor", "Sister Bernice"]
			return names[randi() % names.size()]
		"Guild":
			var names = ["Guildmaster Torval", "Veteran Ranger Orin", "Captain Sarah of the Vanguard", "Dungeon Diver Kane"]
			return names[randi() % names.size()]
		"Syndicate":
			var names = ["Fingers Vane", "Slick Sal", "Madame Whisper", "Garrick the Fence"]
			return names[randi() % names.size()]
		_:
			return "Unknown Merchant"
