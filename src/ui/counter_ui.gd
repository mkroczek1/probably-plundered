class_name CounterUI
extends Control

@onready var portrait_drawer: PortraitDrawer = $HBox/CustomerCol/Portrait
@onready var lbl_cust_name: Label = $HBox/CustomerCol/LblName
@onready var lbl_cust_title: Label = $HBox/CustomerCol/LblTitle
@onready var lbl_patience: Label = $HBox/CustomerCol/LblPatience
@onready var txt_dialogue: RichTextLabel = $HBox/CustomerCol/TxtDialogue

# Item on Counter
@onready var pnl_item: PanelContainer = $HBox/ActionCol/PnlItem
@onready var relic_icon: RelicIconDrawer = $HBox/ActionCol/PnlItem/VBox/RelicIcon
@onready var lbl_item_title: Label = $HBox/ActionCol/PnlItem/VBox/LblTitle
@onready var lbl_item_details: Label = $HBox/ActionCol/PnlItem/VBox/LblDetails
@onready var btn_inspect: Button = $HBox/ActionCol/PnlItem/VBox/BtnInspect

# Offer & Haggle Controls
@onready var lbl_price_info: Label = $HBox/ActionCol/HaggleBox/LblPriceInfo
@onready var spin_offer: SpinBox = $HBox/ActionCol/HaggleBox/SpinOffer
@onready var btn_offer: Button = $HBox/ActionCol/HaggleBox/BtnOffer
@onready var btn_leverage: Button = $HBox/ActionCol/HaggleBox/BtnLeverage
@onready var btn_flatter: Button = $HBox/ActionCol/HaggleBox/BtnFlatter

# Decision Buttons
@onready var btn_accept: Button = $HBox/ActionCol/DecisionBox/BtnAccept
@onready var btn_reject: Button = $HBox/ActionCol/DecisionBox/BtnReject
@onready var btn_confiscate: Button = $HBox/ActionCol/DecisionBox/BtnConfiscate

# Selling to Customer Controls (when customer is buying)
@onready var pnl_shop_select: PanelContainer = $HBox/ActionCol/PnlShopSelect
@onready var opt_shop_inventory: OptionButton = $HBox/ActionCol/PnlShopSelect/VBox/OptInventory
@onready var btn_select_item_to_sell: Button = $HBox/ActionCol/PnlShopSelect/VBox/BtnSelectToSell

var customer: CustomerData = null
var current_negotiated_price: int = 0
var inspection_view_ref: InspectionTableView = null

func _ready() -> void:
	btn_inspect.pressed.connect(_on_inspect_pressed)
	btn_offer.pressed.connect(_on_offer_pressed)
	btn_leverage.pressed.connect(_on_leverage_pressed)
	btn_flatter.pressed.connect(_on_flatter_pressed)
	btn_accept.pressed.connect(_on_accept_pressed)
	btn_reject.pressed.connect(_on_reject_pressed)
	btn_confiscate.pressed.connect(_on_confiscate_pressed)
	btn_select_item_to_sell.pressed.connect(_on_item_to_sell_selected)

	if EventBus:
		EventBus.customer_arrived.connect(load_customer)
		EventBus.item_inspected.connect(_on_item_inspected)

func set_inspection_view(view: InspectionTableView) -> void:
	inspection_view_ref = view

func load_customer(new_cust: CustomerData) -> void:
	customer = new_cust
	if not customer:
		visible = false
		return
	visible = true

	portrait_drawer.portrait_key = customer.portrait_key
	portrait_drawer.expression = "neutral"
	portrait_drawer.queue_redraw()

	lbl_cust_name.text = customer.customer_name
	lbl_cust_title.text = customer.title + " [" + customer.faction + "]"
	_update_patience_display()
	txt_dialogue.text = customer.dialogue_intro

	if customer.action_type == "selling":
		pnl_item.visible = true
		pnl_shop_select.visible = false
		current_negotiated_price = customer.asking_price
		spin_offer.max_value = 100000
		spin_offer.value = current_negotiated_price
		_update_item_card()
		_update_price_display()
		btn_confiscate.visible = customer.faction != "Inquisition"
	else:
		# Customer is BUYING from shop
		pnl_item.visible = false
		pnl_shop_select.visible = true
		_populate_shop_inventory_dropdown()
		lbl_price_info.text = "Customer Budget: ~" + str(customer.budget) + "G (Seeks: " + customer.desired_category.capitalize() + ")"
		btn_confiscate.visible = false

func _update_patience_display() -> void:
	var hearts = ""
	for i in range(customer.max_patience):
		hearts += "❤️" if i < customer.patience else "🖤"
	lbl_patience.text = "Patience: " + hearts

func _update_item_card() -> void:
	var item = customer.offered_item
	if not item: return
	lbl_item_title.text = item.item_name
	var details = "Category: " + item.category.capitalize()
	if item.inspected_visual:
		details += " | " + item.visual_flaw
	if item.inspected_curse and item.is_cursed:
		details += " | ☠️ Cursed"
	if item.inspected_resonance and item.is_counterfeit:
		details += " | ❌ Counterfeit"
	lbl_item_details.text = details

	relic_icon.icon_key = item.icon_key
	relic_icon.is_cursed = item.inspected_curse and item.is_cursed
	relic_icon.is_enchanted = item.inspected_resonance and item.enchantment_name != "Mundane / Inert"
	relic_icon.is_stolen = item.inspected_visual and item.is_stolen
	relic_icon.queue_redraw()

func _update_price_display() -> void:
	if customer.action_type == "selling":
		lbl_price_info.text = "Asking Price: %d G | Appraised Est: %d G" % [
			customer.asking_price, customer.offered_item.get_estimated_value()
		]
		btn_accept.text = "Buy for " + str(int(spin_offer.value)) + " Gold"
	else:
		btn_accept.text = "Sell for " + str(int(spin_offer.value)) + " Gold"

func _on_inspect_pressed() -> void:
	if customer and customer.offered_item and inspection_view_ref:
		inspection_view_ref.setup_inspection(customer.offered_item)

func _on_item_inspected(_tool_name: String, _result: Dictionary) -> void:
	_update_item_card()
	_update_price_display()

func _on_offer_pressed() -> void:
	if not customer: return
	var offer = int(spin_offer.value)
	if customer.action_type == "selling":
		if offer >= customer.asking_price:
			# Generous offer, customer is pleased
			txt_dialogue.text = "A fair patron! Agreed without fuss."
			current_negotiated_price = offer
			portrait_drawer.expression = "happy"
			portrait_drawer.queue_redraw()
		elif offer >= int(customer.asking_price * 0.7):
			# Mild haggle
			current_negotiated_price = offer
			txt_dialogue.text = customer.dialogue_haggle_success
			portrait_drawer.expression = "neutral"
			portrait_drawer.queue_redraw()
		else:
			# Lowball! Loses patience
			var walked = customer.reduce_patience(1)
			_update_patience_display()
			if walked:
				_customer_walks_out()
				return
			txt_dialogue.text = customer.dialogue_haggle_annoyed
			portrait_drawer.expression = "angry"
			portrait_drawer.queue_redraw()
			# Counter-offer
			customer.asking_price = int((customer.asking_price + offer) / 2)
			_update_price_display()
	else: # Buying
		if offer <= customer.budget:
			txt_dialogue.text = customer.dialogue_deal_accepted
			current_negotiated_price = offer
			portrait_drawer.expression = "happy"
			portrait_drawer.queue_redraw()
		else:
			var walked = customer.reduce_patience(1)
			_update_patience_display()
			if walked:
				_customer_walks_out()
				return
			txt_dialogue.text = "Outrageous price! I will not pay more than my purse allows!"
			portrait_drawer.expression = "angry"
			portrait_drawer.queue_redraw()
	
	if EventBus:
		EventBus.sound_requested.emit("haggle_tick")

func _on_leverage_pressed() -> void:
	if not customer: return
	var item = customer.offered_item
	if customer.action_type == "selling" and item:
		if item.inspected_visual and item.is_stolen:
			# Ruthless leverage on stolen goods!
			customer.asking_price = int(customer.asking_price * 0.6)
			spin_offer.value = customer.asking_price
			txt_dialogue.text = "K-Keep your voice down! Fine, take it cheap, just don't tell the watch!"
			portrait_drawer.expression = "panicked"
			portrait_drawer.queue_redraw()
			if EventBus:
				EventBus.sound_requested.emit("haggle_tick")
			_update_price_display()
			return
		elif item.inspected_resonance and item.is_counterfeit:
			# Catch them selling fake magic!
			customer.asking_price = int(customer.asking_price * 0.4)
			spin_offer.value = customer.asking_price
			txt_dialogue.text = "Curse it... your tuning fork heard the dull ring. Alright, peasant scrap price it is."
			portrait_drawer.expression = "embarrassed"
			portrait_drawer.queue_redraw()
			_update_price_display()
			return

	txt_dialogue.text = "You bluffed, but they saw right through it! (" + customer.leverage_text + ")"
	var walked = customer.reduce_patience(1)
	_update_patience_display()
	if walked:
		_customer_walks_out()

func _on_flatter_pressed() -> void:
	if not customer: return
	if customer.weakness in ["gullible", "prideful", "collector"]:
		txt_dialogue.text = customer.dialogue_flattered
		portrait_drawer.expression = "embarrassed"
		portrait_drawer.queue_redraw()
		if customer.action_type == "selling":
			customer.asking_price = int(customer.asking_price * 0.8)
			spin_offer.value = customer.asking_price
		else:
			customer.budget = int(customer.budget * 1.3)
		if EventBus:
			EventBus.sound_requested.emit("coin")
		_update_price_display()
	else:
		txt_dialogue.text = "Your cheap flattery falls on deaf ears."
		customer.reduce_patience(1)
		_update_patience_display()

func _on_accept_pressed() -> void:
	if not customer: return
	var price = int(spin_offer.value)

	if customer.action_type == "selling":
		var item = customer.offered_item
		if GameState.gold < price:
			if EventBus:
				EventBus.toast_requested.emit("Not Enough Gold", "You cannot afford " + str(price) + "G!", "warning")
			return
		GameState.add_gold(-price)
		GameState.add_to_inventory(item)

		# Heat and Reputations
		if item.is_stolen:
			GameState.modify_heat(item.heat_value)
			GameState.modify_faction_rep(item.stolen_from_faction, -8)
			GameState.modify_faction_rep("Syndicate", 5)
		if item.is_cursed:
			GameState.modify_heat(10)
		if customer.archetype == "corrupt_inquisitor":
			GameState.modify_faction_rep("Inquisition", 12)

		if EventBus:
			EventBus.sound_requested.emit("coin")
			EventBus.toast_requested.emit("Item Acquired", "Purchased " + item.item_name + " for " + str(price) + "G", "success")
			EventBus.customer_departed.emit(customer, true)
	else:
		# Player Sold Item to Customer
		var item_idx = opt_shop_inventory.get_selected_id()
		if item_idx < 0 or item_idx >= GameState.shop_inventory.size():
			if EventBus:
				EventBus.toast_requested.emit("No Item Selected", "Choose an item from your shop inventory to sell!", "warning")
			return
		var item = GameState.shop_inventory[item_idx]
		GameState.add_gold(price)
		GameState.remove_from_inventory(item)

		# If sold cursed or counterfeit item without laundering
		if item.is_counterfeit:
			GameState.modify_heat(20)
			GameState.modify_faction_rep(customer.faction, -15)
			if EventBus:
				EventBus.toast_requested.emit("Counterfeit Sold!", "Sold fake gear! Heat increased by 20!", "warning")
		elif item.is_cursed:
			GameState.modify_heat(25)
			GameState.modify_faction_rep("Inquisition", -20)
		else:
			GameState.modify_faction_rep(customer.faction, 8)

		if EventBus:
			EventBus.sound_requested.emit("coin")
			EventBus.toast_requested.emit("Item Sold!", "Sold " + item.item_name + " for " + str(price) + "G", "success")
			EventBus.customer_departed.emit(customer, true)

	GameState.next_customer()

func _on_reject_pressed() -> void:
	if not customer: return
	txt_dialogue.text = customer.dialogue_deal_rejected
	if EventBus:
		EventBus.customer_departed.emit(customer, false)
	GameState.next_customer()

func _on_confiscate_pressed() -> void:
	if not customer: return
	var item = customer.offered_item
	if item and item.is_stolen:
		GameState.modify_faction_rep("Inquisition", 15)
		GameState.modify_faction_rep("Syndicate", -15)
		GameState.modify_heat(-10)
		if EventBus:
			EventBus.toast_requested.emit("Reported Contraband", "Turned over stolen contraband to authorities! Inquisition +15, Heat -10", "info")
	GameState.next_customer()

func _customer_walks_out() -> void:
	txt_dialogue.text = "That is IT! I will not endure this insult any longer!"
	portrait_drawer.expression = "angry"
	portrait_drawer.queue_redraw()
	if EventBus:
		EventBus.sound_requested.emit("door_knock")
		EventBus.toast_requested.emit("Customer Walked Out", customer.customer_name + " lost patience and slammed the door!", "danger")
		EventBus.customer_departed.emit(customer, false)
	GameState.next_customer()

func _populate_shop_inventory_dropdown() -> void:
	opt_shop_inventory.clear()
	for i in range(GameState.shop_inventory.size()):
		var it = GameState.shop_inventory[i]
		var label = it.item_name + " [" + it.category + "] - Val: " + str(it.get_estimated_value()) + "G"
		if it.is_cursed: label += " (Cursed)"
		opt_shop_inventory.add_item(label, i)
	if GameState.shop_inventory.size() > 0:
		_on_item_to_sell_selected()

func _on_item_to_sell_selected() -> void:
	var idx = opt_shop_inventory.get_selected_id()
	if idx >= 0 and idx < GameState.shop_inventory.size():
		var it = GameState.shop_inventory[idx]
		spin_offer.value = it.get_estimated_value()
		_update_price_display()
