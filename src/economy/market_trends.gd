class_name MarketTrends
extends RefCounted

static func generate_daily_gazette(day: int) -> Dictionary:
	var date_str = "Day " + str(day) + " of the 45-Day Reckoning"
	var categories = ["weapon", "armor", "jewelry", "grimoire", "relic"]
	var favored_cat = categories[randi() % categories.size()]
	var disfavored_cat = categories[(randi() + 1) % categories.size()]

	var headlines = [
		"MAW EXPEDITION REACHES 40TH TIER: RELIC RUSH REACHES FEVER PITCH!",
		"BURGLARY AT STERLING MANOR: SHADOW SYNDICATE SUSPECTED!",
		"INQUISITION PURGE: THREE CLANDESTINE SHRINES SMASHED IN LOWER SLUMS!",
		"GOLDEN SCALES SYNDICATE WARNS DEBTORS: 'KNEECAPS ARE NON-NEGOTIABLE'!",
		"STRANGE AURORAS REPORTED OVER OAKHAVEN: VOID DISTORTIONS ON THE RISE!",
		"HERETICAL TOXINS TRACED TO BLACK-MARKET FENCES: ENFORCERS ON HIGH ALERT!"
	]

	var headline = headlines[(day - 1) % headlines.size()]

	# Active Stolen Relic Bounty
	var bounty_victims = ["Duke Aldous Sterling", "Lady Vivienne de Claire", "High Prelate Malakor", "Guildmaster Torval"]
	var victim = bounty_victims[randi() % bounty_victims.size()]
	var bounty_item_name = "Stolen Crested " + favored_cat.capitalize()
	var bounty_reward = 800 + day * 50

	var stolen_bounty = {
		"bounty_id": "BOUNTY-D" + str(day),
		"victim": victim,
		"item_name": bounty_item_name,
		"category": favored_cat,
		"reward": bounty_reward,
		"description": "Lost during the recent festival skirmish. Carries the official hallmark of " + victim + ". High reward for discreet recovery or report."
	}

	# Inquisition Edicts
	var edicts = [
		{"name": "Standard Inspection Protocol", "heat_mod": 1.0, "desc": "Routine parish patrols in effect."},
		{"name": "Heresy Crackdown Edict", "heat_mod": 1.5, "desc": "Possession of cursed/demonic goods generates +50% Heat!"},
		{"name": "Strict Contraband Quarantine", "heat_mod": 2.0, "desc": "Inquisition sweeps are intensified. Raid threshold lowered to 65% Heat!"},
		{"name": "Synod Indulgence Sale", "heat_mod": 0.8, "desc": "Bribes and indulgences are discounted by 20% today."}
	]
	var edict = edicts[(day - 1) % edicts.size()]

	# Underworld Rumor
	var rumors = [
		"Fences in the sunken docks are paying double for purified curse oils.",
		"The Golden Scales Syndicate is watching your shop's daily turnstile.",
		"A rich collector from the Capital is seeking authentic relics this week.",
		"Guard captain can be bribed with a fine vintage to ignore night smoke."
	]
	var rumor = rumors[(day - 1) % rumors.size()]

	return {
		"day": day,
		"date_str": date_str,
		"headline": headline,
		"favored_category": favored_cat,
		"favored_bonus": 1.4,
		"disfavored_category": disfavored_cat,
		"disfavored_penalty": 0.7,
		"stolen_bounty": stolen_bounty,
		"edict": edict,
		"underworld_rumor": rumor
	}
