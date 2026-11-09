class_name GameStateClass
extends Node

const PHASE_MORNING = "MORNING"
const PHASE_COUNTER = "COUNTER_RUSH"
const PHASE_NIGHT = "NIGHT_WORKSHOP"

const SAVE_PATH = "user://probably_plundered_save.json"

# Progression & Time
var current_day: int = 1
var max_days: int = 45
var current_phase: String = PHASE_MORNING

# Economy
var gold: int = 450
var total_debt: int = 500000
var consecutive_missed_payments: int = 0
var daily_overhead_paid_today: bool = false

# Contraband & Heat (0 to 100)
var heat: int = 10

# Faction Reputations (0 to 100)
var faction_reps = {
	"Inquisition": 40,
	"Guild": 50,
	"Syndicate": 30,
	"Aristocracy": 35
}

# Inventories
var shop_inventory: Array[ItemData] = []
var cellar_inventory: Array[ItemData] = []
var cellar_max_slots: int = 4
var foundation_rot: int = 0 # 0 to 100

# Victory Path Counters
var purified_relics_supplied: int = 0
var celestial_diamonds: int = 0
var forged_passports: int = 0

# Workshop Upgrades
var has_holy_cellar_ward: bool = false
var vat_unlocked: bool = true
var grinder_unlocked: bool = true

# Daily state
var daily_gazette: Dictionary = {}
var daily_customers: Array[CustomerData] = []
var current_customer_idx: int = 0
var current_customer: CustomerData = null
var active_item_under_inspection: ItemData = null

# Game outcome state
var game_ended: bool = false
var game_won: bool = false
var end_title: String = ""
var end_message: String = ""

func _ready() -> void:
	start_new_game()

func start_new_game() -> void:
	current_day = 1
	current_phase = PHASE_MORNING
	gold = 450
	total_debt = 500000
	consecutive_missed_payments = 0
	heat = 10
	faction_reps = {
		"Inquisition": 40,
		"Guild": 50,
		"Syndicate": 30,
		"Aristocracy": 35
	}
	shop_inventory.clear()
	cellar_inventory.clear()
	foundation_rot = 0
	purified_relics_supplied = 0
	celestial_diamonds = 0
	forged_passports = 0
	has_holy_cellar_ward = false
	game_ended = false
	game_won = false

	# Add starting items
	var starter_dagger = RelicGenerator.generate_random_relic(1)
	starter_dagger.item_name = "Rusty Rift Dagger"
	starter_dagger.is_stolen = false
	starter_dagger.is_cursed = false
	starter_dagger.is_counterfeit = false
	starter_dagger.base_value = 120
	shop_inventory.append(starter_dagger)

	var starter_amulet = RelicGenerator.generate_random_relic(1)
	starter_amulet.item_name = "Pawned Apprentice Amulet"
	starter_amulet.is_cursed = true
	starter_amulet.curse_type = "Vampiric Drain"
	starter_amulet.base_value = 260
	shop_inventory.append(starter_amulet)

	_setup_morning_phase()

func _setup_morning_phase() -> void:
	current_phase = PHASE_MORNING
	daily_gazette = MarketTrends.generate_daily_gazette(current_day)
	daily_overhead_paid_today = false

	# Deduct daily overhead
	var overhead = LoanManager.get_daily_overhead(current_day)
	if gold >= overhead:
		add_gold(-overhead)
		daily_overhead_paid_today = true
	else:
		# Can't even afford overhead: heat and reputation penalty
		modify_heat(5)
		modify_faction_rep("Guild", -5)
		if EventBus:
			EventBus.toast_requested.emit("Overhead Deficit", "Unable to afford " + str(overhead) + "G daily upkeep!", "warning")

	# Check Weekly Installment
	if LoanManager.is_installment_day(current_day):
		var due = LoanManager.get_installment_due(current_day)
		if gold >= due:
			add_gold(-due)
			total_debt = max(0, total_debt - due)
			consecutive_missed_payments = 0
			if EventBus:
				EventBus.toast_requested.emit("Installment Paid", "Paid " + str(due) + "G to Golden Scales Syndicate.", "success")
		else:
			consecutive_missed_payments += 1
			modify_faction_rep("Syndicate", -25)
			modify_heat(15)
			if EventBus:
				EventBus.toast_requested.emit("MISSED PAYMENT!", "Missed weekly installment of " + str(due) + "G! Repo-goblins are circling...", "danger")

	# Rot cellar if unshielded cursed items exist
	if not has_holy_cellar_ward:
		var cursed_count = 0
		for item in cellar_inventory:
			if item.is_cursed:
				cursed_count += 1
		if cursed_count > 0:
			foundation_rot = min(100, foundation_rot + cursed_count * 8)
			if foundation_rot >= 100:
				trigger_game_over("ABYSSAL_TEAR", false, "The Abyssal Tear", "Uncontained cursed relics in your cellar eroded the dimensional barrier! A demonic vortex ruptured from beneath your floorboards, swallowing The Honest Kobold into the Maw of Gehenna!")
				return

	# Generate queue of customers for Phase 2
	daily_customers.clear()
	var customer_count = randi_range(3, 5)
	for i in range(customer_count):
		var c = CustomerGenerator.generate_customer(current_day, "", shop_inventory)
		daily_customers.append(c)

	current_customer_idx = 0
	current_customer = null

	# Check check win / loss
	_check_end_conditions()

	if EventBus:
		EventBus.phase_changed.emit(current_phase)
		EventBus.day_advanced.emit(current_day)

func advance_to_counter_rush() -> void:
	if game_ended: return
	current_phase = PHASE_COUNTER
	current_customer_idx = 0
	if daily_customers.size() > 0:
		current_customer = daily_customers[0]
		active_item_under_inspection = current_customer.offered_item
	else:
		current_customer = null
		active_item_under_inspection = null

	if EventBus:
		EventBus.phase_changed.emit(current_phase)
		if current_customer:
			EventBus.customer_arrived.emit(current_customer)

func next_customer() -> void:
	current_customer_idx += 1
	if current_customer_idx < daily_customers.size():
		current_customer = daily_customers[current_customer_idx]
		active_item_under_inspection = current_customer.offered_item
		if EventBus:
			EventBus.customer_arrived.emit(current_customer)
	else:
		# All customers processed, move to Night Workshop
		advance_to_night_workshop()

func advance_to_night_workshop() -> void:
	if game_ended: return
	current_phase = PHASE_NIGHT
	current_customer = null
	active_item_under_inspection = null

	# Check for sudden raid if Heat > 75
	var raid_threshold = 65 if daily_gazette.get("edict", {}).get("heat_mod", 1.0) > 1.5 else 75
	if heat >= raid_threshold:
		var raid_chance = float(heat) / 100.0
		if randf() < raid_chance:
			if EventBus:
				EventBus.inquisition_raid_triggered.emit()
			return

	if EventBus:
		EventBus.phase_changed.emit(current_phase)

func finish_day_and_sleep() -> void:
	if game_ended: return
	# End of day checks
	current_day += 1
	if current_day > max_days:
		# Day 45 reached: Final reckoning
		_evaluate_final_day()
		return
	_setup_morning_phase()

func add_gold(amount: int) -> void:
	gold += amount
	if EventBus:
		EventBus.gold_changed.emit(gold, amount)
	_check_end_conditions()

func modify_heat(delta: int) -> void:
	var old_heat = heat
	heat = clampi(heat + delta, 0, 100)
	if EventBus:
		EventBus.heat_changed.emit(heat, heat - old_heat)
	if heat >= 100:
		trigger_game_over("BURNED_AT_THE_STAKE", false, "Burned at the Stake", "Your Shop Heat hit 100%! Grand Inquisitor Tenebros personally led the Sun Synod zealots to kick down your door. Unforgivable demonic heresy was laid bare. You were sentenced to the pyre at dawn!")

func modify_faction_rep(faction_name: String, delta: int) -> void:
	if faction_name in faction_reps:
		var old_rep = faction_reps[faction_name]
		faction_reps[faction_name] = clampi(faction_reps[faction_name] + delta, 0, 100)
		if EventBus:
			EventBus.faction_rep_changed.emit(faction_name, faction_reps[faction_name], faction_reps[faction_name] - old_rep)
		_check_end_conditions()

func add_to_inventory(item: ItemData) -> void:
	item.location = "inventory"
	shop_inventory.append(item)

func remove_from_inventory(item: ItemData) -> void:
	shop_inventory.erase(item)

func move_to_cellar(item: ItemData) -> bool:
	if cellar_inventory.size() >= cellar_max_slots:
		if EventBus:
			EventBus.toast_requested.emit("Cellar Full", "The false-bottom cellar only holds " + str(cellar_max_slots) + " items!", "warning")
		return false
	shop_inventory.erase(item)
	item.location = "cellar"
	cellar_inventory.append(item)
	if EventBus:
		EventBus.cellar_updated.emit()
		EventBus.sound_requested.emit("scale_clunk")
	return true

func move_from_cellar(item: ItemData) -> bool:
	cellar_inventory.erase(item)
	item.location = "inventory"
	shop_inventory.append(item)
	if EventBus:
		EventBus.cellar_updated.emit()
		EventBus.sound_requested.emit("scale_clunk")
	return true

func _check_end_conditions() -> void:
	if game_ended: return

	# Lose Condition 1: Bankruptcy / Debtor's Quarry
	if consecutive_missed_payments >= 2:
		trigger_game_over("DEBTORS_QUARRY", false, "Debtor's Quarry", "You defaulted on two weekly installments. The Golden Scales Goblin Syndicate foreclosed 'The Honest Kobold', snapped your kneecaps, and marched you in chains to the subterranean mana-crystal quarries for eternal hard labor!")
		return

	# Lose Condition 3: Found in the Gutter (Syndicate Hit)
	if faction_reps["Syndicate"] <= 5:
		trigger_game_over("FOUND_IN_THE_GUTTER", false, "Found in the Gutter", "You betrayed the Shadow Fang Syndicate one too many times. An assassin's poisoned crossbow bolt struck you from the alley shadows. Your ledger and shop deeds were stolen before your body hit the cobblestones.")
		return

	# Win Condition 2: The Shadow Baron (Syndicate Victory)
	if faction_reps["Syndicate"] >= 90 and gold >= 350000:
		trigger_game_over("SHADOW_BARON", true, "The Shadow Baron (Syndicate Victory)", "Backed by supreme wealth and total trust of the Shadow Fang, you executed a hostile buyout of your goblin loan officer's syndicate branch. You are now the undisputed Underworld Kingpin of Oakhaven!")
		return

	# Win Condition 3: Purified Benefactor (Guild & Crown Victory)
	if faction_reps["Inquisition"] >= 85 and faction_reps["Guild"] >= 80 and purified_relics_supplied >= 5:
		trigger_game_over("PURIFIED_BENEFACTOR", true, "Purified Benefactor (Guild & Crown Victory)", "By exposing corrupt smuggling rings and supplying the legendary S-Rank hero party with 5 purified sacred relics, they conquered the 100th floor of the Maw! The Crown cleared all your debts and granted you royal knighthood.")
		return

	# Win Condition 4: The Midnight Escape (Renegade Smuggler Victory)
	if celestial_diamonds >= 5 and forged_passports >= 1:
		trigger_game_over("MIDNIGHT_ESCAPE", true, "The Midnight Escape (Renegade Smuggler)", "With a pouch packed with uncut celestial diamonds and forged royal diplomatic credentials, you slipped onto a luxury night airship bound for the neutral coast. The goblins and inquisitors were left holding empty leases!")
		return

func _evaluate_final_day() -> void:
	if game_ended: return
	if gold >= total_debt:
		add_gold(-total_debt)
		total_debt = 0
		trigger_game_over("FREE_MERCHANT", true, "Free Merchant (Standard Victory)", "Day 45 arrived! You deposited a towering mountain of 500,000 Gold onto the loan officer's desk. The goblin signed over the freehold title deed to 'The Honest Kobold' with trembling hands. You are truly your own master!")
	else:
		trigger_game_over("DEBTORS_QUARRY", false, "Debtor's Quarry (Day 45 Default)", "The 45-day deadline struck at midnight! You had " + str(gold) + "G out of the required " + str(total_debt) + "G. The Goblin Enforcers locked the iron gates and dragged you down into the crystal quarries.")

func trigger_game_over(condition_id: String, victory: bool, title: String, message: String) -> void:
	game_ended = true
	game_won = victory
	end_title = title
	end_message = message
	if EventBus:
		EventBus.game_over.emit(condition_id, victory, title, message)
		EventBus.sound_requested.emit("victory" if victory else "game_over")
