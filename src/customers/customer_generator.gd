class_name CustomerGenerator
extends RefCounted

const FIRST_NAMES = ["Klaus", "Pip", "Eleanor", "Malakor", "Vance", "Lyra", "Garrick", "Bryn", "Zane", "Rowan", "Selene"]

static func generate_customer(day: int, force_archetype: String = "", shop_inventory: Array = []) -> CustomerData:
	var customer = CustomerData.new()
	var archetypes = ["chuunibyou_mage", "rookie_rogue", "tsundere_paladin", "corrupt_inquisitor", "curio_collector", "dungeon_scavenger"]
	var selected_arch = force_archetype
	if selected_arch.is_empty():
		# On earlier days, more rogues and scavengers. Later days bring collectors and inquisitors.
		var weights = [20, 30, 20, 10 + day, 10 + day * 2, 25]
		var total_w = 0
		for w in weights: total_w += w
		var roll = randi() % total_w
		var acc = 0
		for i in range(archetypes.size()):
			acc += weights[i]
			if roll < acc:
				selected_arch = archetypes[i]
				break
	customer.archetype = selected_arch

	# Can they buy from our shop or sell to us?
	# Curio Collectors almost always buy; Rogues almost always sell; Inquisitors sell confiscated goods or demand bribes.
	var wants_to_buy = false
	if selected_arch == "curio_collector":
		wants_to_buy = shop_inventory.size() > 0 and randf() < 0.8
	elif selected_arch == "chuunibyou_mage":
		wants_to_buy = shop_inventory.size() > 0 and randf() < 0.5
	elif selected_arch == "dungeon_scavenger":
		wants_to_buy = shop_inventory.size() > 0 and randf() < 0.3
	else:
		wants_to_buy = false

	customer.action_type = "buying" if wants_to_buy else "selling"

	match selected_arch:
		"chuunibyou_mage":
			customer.customer_name = "Klaus the Void-Touched"
			customer.title = "Apprentice of the Black Eclipse"
			customer.portrait_key = "mage"
			customer.faction = "Independent"
			customer.weakness = "gullible"
			customer.patience = 4
			customer.max_patience = 4
			customer.dialogue_intro = "Heh... mortal shopkeeper, avert thine eyes if thou valuest thy sanity. My right hand trembles with sealed abyssal fire..."
			customer.dialogue_deal_accepted = "A worthy tribute. The dark cosmos smiles upon our covenant!"
			customer.dialogue_deal_rejected = "Tch! Barbarian! You know nothing of the true arcane arts!"
			customer.dialogue_haggle_success = "Hmph, thy silver tongue rivals the serpents of the nether..."
			customer.dialogue_haggle_annoyed = "Do not insult the Avatar of the Void with such peasant coppers!"
			customer.dialogue_flattered = "Guh! You... you truly recognize my supreme demonic destiny?! In that case, I shall grant a discount!"
			customer.leverage_text = "Flatter their delusions of forbidden arcane godhood."

		"rookie_rogue":
			customer.customer_name = "Pip the Nimble"
			customer.title = "Alley Cat of the Lower Spire"
			customer.portrait_key = "rogue"
			customer.faction = "Syndicate"
			customer.weakness = "desperate"
			customer.patience = 3
			customer.max_patience = 3
			customer.dialogue_intro = "Psst! Hey boss. Keep it down. Got some fresh iron straight from... uh, an abandoned cart. Cash only, no questions."
			customer.dialogue_deal_accepted = "Good doing business! Don't tell the city watch where you got this."
			customer.dialogue_deal_rejected = "Forget it then! I'll take it to the docks before you rob me blind!"
			customer.dialogue_haggle_success = "Come on boss, you're killing me here! Fine, take it..."
			customer.dialogue_haggle_annoyed = "Are you kidding me?! I bled for this! Give me a fair cut!"
			customer.dialogue_flattered = "Wait, you really think my stealth was slick? Heh... maybe I'll knock a few coins off."
			customer.leverage_text = "Pressure them with stolen marks: 'I'm taking all the risk here, kid.'"

		"tsundere_paladin":
			customer.customer_name = "Dame Eleanor"
			customer.title = "Disgraced Knight of the Solar Vow"
			customer.portrait_key = "paladin"
			customer.faction = "Guild"
			customer.weakness = "prideful"
			customer.patience = 4
			customer.max_patience = 4
			customer.dialogue_intro = "D-Don't look at me like that! I'm only pawning this sacred heirloom because the innkeeper insists on coin, not vows of chivalry!"
			customer.dialogue_deal_accepted = "T-Thank you... Not that I'm grateful or anything! I will reclaim it once my quest rewards arrive!"
			customer.dialogue_deal_rejected = "How dare you! This blade has cleaved demonic hordes! Good day, cur!"
			customer.dialogue_haggle_success = "Ugh... my honor demands I accept. Just hand over the pouch before anyone sees us."
			customer.dialogue_haggle_annoyed = "Have you no shame?! Quibbling over holy steel like a market fishwife?!"
			customer.dialogue_flattered = "W-What?! You find my sword stance noble?! H-Hmph, well, you do have an eye for valor..."
			customer.leverage_text = "Appeal to their knighthood or exploit their mortification over tavern debt."

		"corrupt_inquisitor":
			customer.customer_name = "Inquisitor Malakor"
			customer.title = "Special Tribune of the Sun Synod"
			customer.portrait_key = "inquisitor"
			customer.faction = "Inquisition"
			customer.weakness = "corrupt"
			customer.patience = 5
			customer.max_patience = 5
			customer.dialogue_intro = "Peace of the Sun upon your modest establishment, broker. I come bearing... 'confiscated assets'. Purely for ecclesiastical liquidation."
			customer.dialogue_deal_accepted = "A pious transaction. The Synod notes your cooperation, citizen."
			customer.dialogue_deal_rejected = "Suspicious reluctance. Perhaps your cellar requires a formal sanctification search?"
			customer.dialogue_haggle_success = "A keen appraiser. Very well. Let us balance the ledger."
			customer.dialogue_haggle_annoyed = "You test my patience, broker. Remember whose favor keeps your doors unsealed."
			customer.dialogue_flattered = "Praise well-spoken. Loyalty to the Sun Synod is always repaid."
			customer.leverage_text = "Offer polite bribes or cite Synod indulgences to pacify."

		"curio_collector":
			customer.customer_name = "Lord Vance Sterling"
			customer.title = "Curio Connoisseur & Imperial Patron"
			customer.portrait_key = "collector"
			customer.faction = "Aristocracy"
			customer.weakness = "collector"
			customer.patience = 3
			customer.max_patience = 3
			customer.dialogue_intro = "Greetings, merchant. My salon requires an antiquity of exquisite pedigree. Spare me the common dross; show me wonder."
			customer.dialogue_deal_accepted = "Splendid! An exquisite piece for my winter exhibition. Here is your draft."
			customer.dialogue_deal_rejected = "Pedestrian trash. Do not waste my carriage fare again."
			customer.dialogue_haggle_success = "A firm negotiator. Quality warrants generous patronage. Settled."
			customer.dialogue_haggle_annoyed = "Pauper's squabble. I shall withdraw my offer if you continue this vulgarity."
			customer.dialogue_flattered = "Indeed! Few in this frontier mud pit comprehend the provenance of true high art!"
			customer.leverage_text = "Provide certificates and weave historical legends to multiply price."

		_: # dungeon_scavenger
			customer.customer_name = "Garrick the Delver"
			customer.title = "Veteran Porter of the 4th Maw"
			customer.portrait_key = "scavenger"
			customer.faction = "Guild"
			customer.weakness = "desperate"
			customer.patience = 4
			customer.max_patience = 4
			customer.dialogue_intro = "Found this deep in the bone pits. Smells like sulfur, but heavy as a dead troll. Got gold for it?"
			customer.dialogue_deal_accepted = "Fair enough. Time for hot stew and cheap ale."
			customer.dialogue_deal_rejected = "Bah! Should've traded it to the goblins."
			customer.dialogue_haggle_success = "Alright, alright, deal. My boots have holes anyway."
			customer.dialogue_haggle_annoyed = "Don't pinch coppers on a guy who hauled it ten miles uphill!"
			customer.dialogue_flattered = "Ha! Finally someone who respects the delvers!"
			customer.leverage_text = "Remind them how much potions cost at the guild gate."

	if customer.action_type == "selling":
		customer.offered_item = RelicGenerator.generate_random_relic(day)
		# Corrupt Inquisitor brings heretical / cursed relics confiscated from cultists
		if selected_arch == "corrupt_inquisitor":
			customer.offered_item.is_cursed = true
			customer.offered_item.smoke_reaction = "Violet Demonic Flame (Salt whispers in agonized tongues)"
			customer.offered_item.curse_type = "Necrotic Rot"
			customer.offered_item.curse_description = "Confiscated heretical artifact carrying an active necrotic blight."
			customer.offered_item.base_value = int(customer.offered_item.base_value * 1.8)
		# Rogue brings stolen goods
		elif selected_arch == "rookie_rogue":
			customer.offered_item.is_stolen = true
			customer.offered_item.stolen_from_faction = "Aristocracy"
			customer.offered_item.stolen_victim = "Duke Aldous Sterling"
			customer.offered_item.visual_flaw = "Serial runes chiseled off with crude rasp"

		# Calculate asking price
		var est = customer.offered_item.base_value
		if customer.weakness == "desperate":
			customer.asking_price = int(est * randf_range(0.65, 0.90))
		elif customer.weakness == "gullible":
			customer.asking_price = int(est * randf_range(0.50, 0.85))
		else:
			customer.asking_price = int(est * randf_range(0.85, 1.25))
		customer.current_offer = customer.asking_price

	else: # buying
		var budget_mult = randf_range(1.5, 3.5) if selected_arch == "curio_collector" else randf_range(1.1, 1.8)
		customer.budget = int(300 * budget_mult + day * 40)
		var cats = ["weapon", "jewelry", "relic", "grimoire", "armor"]
		customer.desired_category = cats[randi() % cats.size()]

	return customer
