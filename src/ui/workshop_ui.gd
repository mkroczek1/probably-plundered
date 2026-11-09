class_name WorkshopUI
extends Control

@onready var opt_inventory: OptionButton = $VBox/HBox/InvCol/OptInventory
@onready var pnl_item_preview: PanelContainer = $VBox/HBox/InvCol/PnlPreview
@onready var icon_preview: RelicIconDrawer = $VBox/HBox/InvCol/PnlPreview/VBox/RelicIcon
@onready var lbl_preview_info: Label = $VBox/HBox/InvCol/PnlPreview/VBox/LblInfo

# Stations
@onready var btn_curse_wash: Button = $VBox/HBox/StationsCol/VBoxCurse/HBoxCurseBtns/BtnPurify
@onready var btn_extract_toxin: Button = $VBox/HBox/StationsCol/VBoxCurse/HBoxCurseBtns/BtnExtractToxin
@onready var btn_grind_runes: Button = $VBox/HBox/StationsCol/VBoxGrind/BtnGrind
@onready var btn_store_cellar: Button = $VBox/HBox/StationsCol/VBoxCellar/BtnStoreCellar

# Cellar Panel
@onready var opt_cellar: OptionButton = $VBox/HBox/CellarCol/OptCellar
@onready var btn_retrieve_cellar: Button = $VBox/HBox/CellarCol/BtnRetrieveCellar
@onready var lbl_cellar_status: Label = $VBox/HBox/CellarCol/LblCellarStatus

# Black Market & Forgery
@onready var btn_bribe_police: Button = $VBox/HBox/StationsCol/VBoxFence/BtnBribe
@onready var btn_forge_passport: Button = $VBox/HBox/StationsCol/VBoxFence/BtnForgePassport
@onready var btn_buy_diamond: Button = $VBox/HBox/StationsCol/VBoxFence/BtnBuyDiamond
@onready var btn_holy_ward: Button = $VBox/HBox/StationsCol/VBoxFence/BtnHolyWard

# Sleep button
@onready var btn_sleep: Button = $VBox/BtnSleep

func _ready() -> void:
	opt_inventory.item_selected.connect(_on_inventory_selected)
	btn_curse_wash.pressed.connect(_on_purify_pressed)
	btn_extract_toxin.pressed.connect(_on_extract_toxin_pressed)
	btn_grind_runes.pressed.connect(_on_grind_runes_pressed)
	btn_store_cellar.pressed.connect(_on_store_cellar_pressed)
	btn_retrieve_cellar.pressed.connect(_on_retrieve_cellar_pressed)
	btn_bribe_police.pressed.connect(_on_bribe_police_pressed)
	btn_forge_passport.pressed.connect(_on_forge_passport_pressed)
	btn_buy_diamond.pressed.connect(_on_buy_diamond_pressed)
	btn_holy_ward.pressed.connect(_on_holy_ward_pressed)
	btn_sleep.pressed.connect(_on_sleep_pressed)

	if EventBus:
		EventBus.phase_changed.connect(_on_phase_changed)
		EventBus.cellar_updated.connect(refresh_ui)

func _on_phase_changed(phase: String) -> void:
	if phase == GameState.PHASE_NIGHT:
		visible = true
		refresh_ui()
	else:
		visible = false

func refresh_ui() -> void:
	opt_inventory.clear()
	for i in range(GameState.shop_inventory.size()):
		var it = GameState.shop_inventory[i]
		var label = it.item_name
		if it.is_cursed: label += " [☠️ Cursed]"
		if it.is_stolen: label += " [⚠️ Stolen]"
		opt_inventory.add_item(label, i)

	opt_cellar.clear()
	for i in range(GameState.cellar_inventory.size()):
		var it = GameState.cellar_inventory[i]
		var label = it.item_name
		if it.is_cursed: label += " [☠️ Cursed]"
		opt_cellar.add_item(label, i)

	var rot_warning = " (Holy Ward Active)" if GameState.has_holy_cellar_ward else (" Foundation Rot: " + str(GameState.foundation_rot) + "%")
	lbl_cellar_status.text = "Cellar Slots: %d / %d |%s" % [
		GameState.cellar_inventory.size(), GameState.cellar_max_slots, rot_warning
	]

	if GameState.shop_inventory.size() > 0:
		_on_inventory_selected(0)
	else:
		lbl_preview_info.text = "No items in shop inventory."
		pnl_item_preview.visible = false

	# Update Victory item counts
	btn_forge_passport.text = "Forge Diplomatic Passport (1,200G) [Have: %d]" % GameState.forged_passports
	btn_buy_diamond.text = "Buy Celestial Diamond (50,000G) [Have: %d/5]" % GameState.celestial_diamonds
	btn_holy_ward.text = "Install Holy Cellar Ward (1,500G)" if not GameState.has_holy_cellar_ward else "Holy Ward Installed (Active)"
	btn_holy_ward.disabled = GameState.has_holy_cellar_ward

func _get_selected_item() -> ItemData:
	var idx = opt_inventory.get_selected_id()
	if idx >= 0 and idx < GameState.shop_inventory.size():
		return GameState.shop_inventory[idx]
	return null

func _on_inventory_selected(idx: int) -> void:
	if idx < 0 or idx >= GameState.shop_inventory.size():
		return
	var item = GameState.shop_inventory[idx]
	pnl_item_preview.visible = true
	icon_preview.icon_key = item.icon_key
	icon_preview.is_cursed = item.is_cursed
	icon_preview.is_stolen = item.is_stolen
	icon_preview.is_enchanted = item.enchantment_name != "Mundane / Inert"
	icon_preview.queue_redraw()

	var info = "[b]" + item.item_name + "[/b] (" + item.category.capitalize() + ")\n"
	info += "Value: " + str(item.get_estimated_value()) + "G | Material: " + item.true_material + "\n"
	if item.is_cursed:
		info += "☠️ Curse: " + item.curse_type + " (" + item.curse_description + ")\n"
	if item.is_stolen:
		info += "⚠️ Stolen from: " + item.stolen_from_faction + " (" + item.stolen_victim + ")\n"
	lbl_preview_info.text = info

	btn_curse_wash.disabled = not item.is_cursed
	btn_extract_toxin.disabled = not item.is_cursed
	btn_grind_runes.disabled = not item.is_stolen

func _on_purify_pressed() -> void:
	var item = _get_selected_item()
	if not item or not item.is_cursed: return
	item.is_cursed = false
	item.curse_type = ""
	item.curse_description = "Sanctified and purified in blessed alchemical vats."
	item.smoke_reaction = "Clear Pure White Vapor"
	item.inspected_curse = true
	item.base_value = int(item.base_value * 1.3)
	GameState.purified_relics_supplied += 1
	GameState.modify_faction_rep("Inquisition", 10)
	GameState.modify_faction_rep("Guild", 8)
	GameState.modify_heat(-5)

	if EventBus:
		EventBus.sound_requested.emit("vat_bubble")
		EventBus.toast_requested.emit("Relic Purified!", item.item_name + " was cleansed of malevolent curse! Inquisition rep increased.", "success")
	refresh_ui()

func _on_extract_toxin_pressed() -> void:
	var item = _get_selected_item()
	if not item or not item.is_cursed: return
	item.is_cursed = false
	item.smoke_reaction = "Clear Pure White Vapor"
	var payout = 650 + GameState.current_day * 40
	GameState.add_gold(payout)
	GameState.modify_heat(15)
	GameState.modify_faction_rep("Syndicate", 12)
	GameState.modify_faction_rep("Inquisition", -10)

	if EventBus:
		EventBus.sound_requested.emit("vat_bubble")
		EventBus.toast_requested.emit("Curse Harvested!", "Bottled toxic essence sold to shadow assassins for +" + str(payout) + "G! Heat +15", "warning")
	refresh_ui()

func _on_grind_runes_pressed() -> void:
	var item = _get_selected_item()
	if not item or not item.is_stolen: return
	item.is_stolen = false
	item.visual_flaw = "Re-stamped with generic Guild artisan hallmark."
	item.stolen_from_faction = ""
	item.stolen_victim = ""
	item.heat_value = 0
	item.inspected_visual = true
	GameState.modify_heat(-15)

	if EventBus:
		EventBus.sound_requested.emit("anvil_strike")
		EventBus.toast_requested.emit("Hallmarks Scrubbed", "Chiseled off noble crests! Item is no longer recognized as stolen. Heat -15", "success")
	refresh_ui()

func _on_store_cellar_pressed() -> void:
	var item = _get_selected_item()
	if not item: return
	if GameState.move_to_cellar(item):
		refresh_ui()

func _on_retrieve_cellar_pressed() -> void:
	var idx = opt_cellar.get_selected_id()
	if idx >= 0 and idx < GameState.cellar_inventory.size():
		var item = GameState.cellar_inventory[idx]
		GameState.move_from_cellar(item)
		refresh_ui()

func _on_bribe_police_pressed() -> void:
	if GameState.gold < 400:
		if EventBus:
			EventBus.toast_requested.emit("Not Enough Gold", "Need 400G for police bribes!", "warning")
		return
	GameState.add_gold(-400)
	GameState.modify_heat(-25)
	GameState.modify_faction_rep("Inquisition", 5)
	if EventBus:
		EventBus.sound_requested.emit("coin")
		EventBus.toast_requested.emit("Bribe Paid", "Passed discreet coppers to parish watch. Heat reduced by 25!", "success")

func _on_forge_passport_pressed() -> void:
	if GameState.gold < 1200:
		if EventBus:
			EventBus.toast_requested.emit("Not Enough Gold", "Need 1,200G to forge royal diplomatic papers!", "warning")
		return
	GameState.add_gold(-1200)
	GameState.forged_passports += 1
	GameState.modify_heat(10)
	if EventBus:
		EventBus.sound_requested.emit("monocle")
		EventBus.toast_requested.emit("Diplomatic Papers Forged", "Forged royal passport created! One step closer to The Midnight Escape.", "success")
	refresh_ui()

func _on_buy_diamond_pressed() -> void:
	if GameState.gold < 50000:
		if EventBus:
			EventBus.toast_requested.emit("Not Enough Gold", "Need 50,000G to buy an uncut celestial diamond!", "warning")
		return
	GameState.add_gold(-50000)
	GameState.celestial_diamonds += 1
	if EventBus:
		EventBus.sound_requested.emit("coin")
		EventBus.toast_requested.emit("Celestial Diamond Acquired", "Purchased uncut diamond (%d/5) for midnight smuggling airship!" % GameState.celestial_diamonds, "success")
	refresh_ui()

func _on_holy_ward_pressed() -> void:
	if GameState.gold < 1500:
		if EventBus:
			EventBus.toast_requested.emit("Not Enough Gold", "Need 1,500G to purchase Holy Cellar Wards!", "warning")
		return
	GameState.add_gold(-1500)
	GameState.has_holy_cellar_ward = true
	GameState.foundation_rot = 0
	if EventBus:
		EventBus.sound_requested.emit("fork_chime")
		EventBus.toast_requested.emit("Holy Ward Installed", "Sanctified silver runes etched in cellar! Prevents foundation rot from cursed items.", "success")
	refresh_ui()

func _on_sleep_pressed() -> void:
	GameState.finish_day_and_sleep()
