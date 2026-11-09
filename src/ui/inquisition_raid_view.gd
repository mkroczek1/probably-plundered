class_name InquisitionRaidView
extends Control

@onready var lbl_timer: Label = $VBox/LblTimer
@onready var bar_timer: ProgressBar = $VBox/BarTimer
@onready var grid_counter_items: GridContainer = $VBox/GridItems
@onready var btn_seal_trapdoor: Button = $VBox/HBoxActions/BtnSealTrapdoor
@onready var btn_light_incense: Button = $VBox/HBoxActions/BtnLightIncense
@onready var btn_open_door: Button = $VBox/HBoxActions/BtnOpenDoor
@onready var lbl_status: Label = $VBox/LblStatus

var time_left: float = 20.0
var raid_active: bool = false
var trapdoor_sealed: bool = false
var incense_lit: bool = false
var items_on_counter: Array[ItemData] = []

func _ready() -> void:
	btn_seal_trapdoor.pressed.connect(_on_seal_trapdoor_pressed)
	btn_light_incense.pressed.connect(_on_light_incense_pressed)
	btn_open_door.pressed.connect(_on_open_door_pressed)

	if EventBus:
		EventBus.inquisition_raid_triggered.connect(start_raid)

func start_raid() -> void:
	visible = true
	raid_active = true
	time_left = 20.0
	trapdoor_sealed = false
	incense_lit = false
	btn_seal_trapdoor.text = "🪤 Seal Floor-Safe Trapdoor"
	btn_seal_trapdoor.disabled = false
	btn_light_incense.text = "🕯️ Light Holy Incense Brazier"
	btn_light_incense.disabled = false
	lbl_status.text = "INQUISITION AT THE DOOR! HIDE CONTRABAND BEFORE TIME RUNS OUT!"

	# Populate counter with shop inventory items
	items_on_counter.clear()
	for it in GameState.shop_inventory:
		items_on_counter.append(it)
	# If empty, add a couple dummy cursed items for the panic
	if items_on_counter.is_empty():
		items_on_counter.append(RelicGenerator.generate_random_relic(GameState.current_day))

	_rebuild_item_buttons()

	if EventBus:
		EventBus.sound_requested.emit("knock")
		EventBus.sound_requested.emit("warning")

func _process(delta: float) -> void:
	if not raid_active: return
	time_left -= delta
	bar_timer.value = (time_left / 20.0) * 100.0
	lbl_timer.text = "TIME TO INQUISITION ENTRY: %.1f SECONDS!" % max(0.0, time_left)

	if time_left <= 0:
		raid_active = false
		_resolve_raid()

func _rebuild_item_buttons() -> void:
	for child in grid_counter_items.get_children():
		child.queue_free()

	for item in items_on_counter:
		var btn = Button.new()
		var badge = ""
		if item.is_cursed: badge += " [☠️ CURSED]"
		if item.is_stolen: badge += " [⚠️ HOT]"
		btn.text = item.item_name + badge + " ➔ STASH"
		btn.custom_minimum_size = Vector2(240, 44)
		if item.is_cursed or item.is_stolen:
			btn.add_theme_color_override("font_color", Color(1.0, 0.4, 0.4))
		btn.pressed.connect(_stash_item.bind(item))
		grid_counter_items.add_child(btn)

func _stash_item(item: ItemData) -> void:
	if trapdoor_sealed:
		lbl_status.text = "Trapdoor is sealed! Unseal it first or keep it closed!"
		return
	items_on_counter.erase(item)
	GameState.move_to_cellar(item)
	if EventBus:
		EventBus.sound_requested.emit("scale_clunk")
	_rebuild_item_buttons()

func _on_seal_trapdoor_pressed() -> void:
	trapdoor_sealed = true
	btn_seal_trapdoor.text = "✓ Trapdoor Sealed Tight!"
	btn_seal_trapdoor.disabled = true
	if EventBus:
		EventBus.sound_requested.emit("anvil_strike")

func _on_light_incense_pressed() -> void:
	incense_lit = true
	btn_light_incense.text = "✓ Holy Incense Burning (Sulfur Masked)"
	btn_light_incense.disabled = true
	if EventBus:
		EventBus.sound_requested.emit("smoke_clean")

func _on_open_door_pressed() -> void:
	if raid_active:
		raid_active = false
		_resolve_raid()

func _resolve_raid() -> void:
	var contraband_found = false
	var contraband_names = []

	for item in items_on_counter:
		if item.is_cursed or item.is_stolen:
			contraband_found = true
			contraband_names.append(item.item_name)

	if not trapdoor_sealed and GameState.cellar_inventory.size() > 0:
		contraband_found = true
		contraband_names.append("Open Trapdoor revealing contraband stash")

	if not incense_lit:
		for item in GameState.cellar_inventory:
			if item.is_cursed:
				contraband_found = true
				contraband_names.append("Sulfur fumes of unsealed cursed relics")
				break

	if contraband_found:
		var bribe_cost = 600 + GameState.current_day * 50
		if GameState.gold >= bribe_cost:
			GameState.add_gold(-bribe_cost)
			GameState.modify_heat(-20)
			GameState.modify_faction_rep("Inquisition", -10)
			lbl_status.text = "INSPECTION FAILED! Paid emergency bribe of %dG to Inquisitor! Contraband seized: %s" % [
				bribe_cost, ", ".join(contraband_names)
			]
			if EventBus:
				EventBus.sound_requested.emit("coin")
				EventBus.toast_requested.emit("Raid Bribe Paid", "Inquisitor extorted " + str(bribe_cost) + "G! Heat -20", "warning")
		else:
			# Cannot afford bribe!
			GameState.trigger_game_over(
				"HERESY_PURGE",
				false,
				"Burned at the Stake (Inquisition Raid)",
				"The inquisitors discovered illicit contraband in your shop: " + ", ".join(contraband_names) + ". Unable to pay the steep indulgence bribe, you were condemned as a heretic!"
			)
			visible = false
			return
	else:
		# Completely clean!
		GameState.modify_heat(-35)
		GameState.modify_faction_rep("Inquisition", 12)
		lbl_status.text = "INSPECTION PASSED! The Inquisitor found only legitimate wares. 'The Sun smiles upon your piety.' Heat reduced by 35!"
		if EventBus:
			EventBus.sound_requested.emit("fork_chime")
			EventBus.toast_requested.emit("Inquisition Raid Passed!", "Shop was clean! Heat -35, Inquisition +12", "success")

	# Close raid view after 2.5 seconds
	var tween = create_tween()
	tween.tween_interval(2.5)
	tween.tween_callback(func():
		visible = false
		if EventBus:
			EventBus.phase_changed.emit(GameState.PHASE_NIGHT)
	)
