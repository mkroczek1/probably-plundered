class_name CustomerData
extends Resource

@export var customer_name: String = "Adventurer"
@export var title: String = "Greenhorn Scavenger"
@export var archetype: String = "rookie_rogue" # chuunibyou_mage, rookie_rogue, tsundere_paladin, corrupt_inquisitor, curio_collector, dungeon_scavenger
@export var faction: String = "Independent" # Inquisition, Guild, Syndicate, Aristocracy, Independent
@export var portrait_key: String = "rogue"

@export var action_type: String = "selling" # selling, buying, inspection_bribe
@export var offered_item: ItemData = null
@export var desired_category: String = "weapon"

@export var asking_price: int = 100
@export var budget: int = 300
@export var current_offer: int = 100
@export var patience: int = 4
@export var max_patience: int = 4

# Leverage and social state
@export var weakness: String = "desperate" # desperate, gullible, prideful, corrupt, collector
@export var leverage_discovered: bool = false
@export var leverage_text: String = ""

# Expressive Dialogues
@export var dialogue_intro: String = ""
@export var dialogue_deal_accepted: String = ""
@export var dialogue_deal_rejected: String = ""
@export var dialogue_haggle_success: String = ""
@export var dialogue_haggle_annoyed: String = ""
@export var dialogue_leverage_used: String = ""
@export var dialogue_flattered: String = ""

func reduce_patience(amount: int = 1) -> bool:
	patience -= amount
	return patience <= 0
