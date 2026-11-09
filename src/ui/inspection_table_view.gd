class_name InspectionTableView
extends Control

@onready var icon_display: RelicIconDrawer = $Panel/VBox/HBoxTable/ItemCenter/RelicIcon
@onready var lbl_item_name: Label = $Panel/VBox/HBoxTable/ItemCenter/LblItemName
@onready var lbl_category: Label = $Panel/VBox/HBoxTable/ItemCenter/LblCategory
@onready var lbl_appraised_val: Label = $Panel/VBox/HBoxTable/ItemCenter/LblAppraised

@onready var btn_monocle: Button = $Panel/VBox/HBoxTable/ToolsCol/BtnMonocle
@onready var btn_tuning_fork: Button = $Panel/VBox/HBoxTable/ToolsCol/BtnTuningFork
@onready var btn_litmus: Button = $Panel/VBox/HBoxTable/ToolsCol/BtnLitmus
@onready var btn_scale: Button = $Panel/VBox/HBoxTable/ToolsCol/BtnScale

@onready var txt_log: RichTextLabel = $Panel/VBox/HBoxTable/NotebookCol/TxtLog
@onready var btn_back: Button = $Panel/VBox/BtnBack

var active_item: ItemData = null

func _ready() -> void:
	btn_monocle.pressed.connect(_on_monocle_pressed)
	btn_tuning_fork.pressed.connect(_on_tuning_fork_pressed)
	btn_litmus.pressed.connect(_on_litmus_pressed)
	btn_scale.pressed.connect(_on_scale_pressed)
	btn_back.pressed.connect(_on_back_pressed)

func setup_inspection(item: ItemData) -> void:
	active_item = item
	if not active_item:
		visible = false
		return
	visible = true
	lbl_item_name.text = active_item.item_name
	lbl_category.text = "Category: " + active_item.category.capitalize() + " | Claimed Material: " + (active_item.disguised_material if active_item.disguised_material != "" else active_item.true_material)
	
	icon_display.icon_key = active_item.icon_key
	icon_display.is_cursed = active_item.inspected_curse and active_item.is_cursed
	icon_display.is_enchanted = active_item.inspected_resonance and active_item.enchantment_name != "Mundane / Inert"
	icon_display.is_stolen = active_item.inspected_visual and active_item.is_stolen
	icon_display.queue_redraw()

	_update_notebook()

func _update_notebook() -> void:
	if not active_item:
		return
	var bb = "[b]=== APPRAISER'S FELT NOTEBOOK ===[/b]\n\n"
	
	# Monocle
	if active_item.inspected_visual:
		bb += "[color=#fbbf24]● Monocle Visual:[/color] " + active_item.visual_flaw + "\n"
		if active_item.is_stolen:
			bb += "   [color=#ef4444]⚠️ STOLEN CONTRABAND (" + active_item.stolen_from_faction + ")[/color]\n"
	else:
		bb += "[color=#9ca3af]○ Monocle: [Uninspected][/color]\n"

	# Tuning Fork
	if active_item.inspected_resonance:
		if active_item.is_counterfeit:
			bb += "[color=#ef4444]● Mana Fork: Dissonant Buzz! " + active_item.counterfeit_reason + "[/color]\n"
		elif active_item.enchantment_name != "Mundane / Inert":
			bb += "[color=#38bdf8]● Mana Fork: Pure Celestial Chime (" + active_item.enchantment_name + ")[/color]\n"
		else:
			bb += "[color=#d1d5db]● Mana Fork: Dull Thud (Mundane non-magical)[/color]\n"
	else:
		bb += "[color=#9ca3af]○ Mana Fork: [Uninspected][/color]\n"

	# Litmus Salt
	if active_item.inspected_curse:
		if active_item.is_cursed:
			bb += "[color=#c084fc]● Litmus Salt: ☠️ VIOLET BOIL! Curse: " + active_item.curse_type + "[/color]\n"
			bb += "   [color=#e9d5ff]" + active_item.curse_description + "[/color]\n"
		else:
			bb += "[color=#4ade80]● Litmus Salt: Pure White Mist (Clean & Sanctified)[/color]\n"
	else:
		bb += "[color=#9ca3af]○ Litmus Salt: [Uninspected][/color]\n"

	# Balance Scale
	if active_item.inspected_weight:
		bb += "[color=#fb923c]● Balance Scale:[/color] " + active_item.scale_result + "\n"
		bb += "   Mass: " + str(active_item.actual_weight) + " kg (Expected: " + str(active_item.expected_weight) + " kg)\n"
	else:
		bb += "[color=#9ca3af]○ Balance Scale: [Uninspected][/color]\n"

	bb += "\n[color=#fef08a]Estimated Market Value:[/color] " + str(active_item.get_estimated_value()) + " Gold"
	txt_log.bbcode_text = bb
	lbl_appraised_val.text = "Appraised: " + str(active_item.get_estimated_value()) + " G"

	# Update visual badges
	icon_display.is_cursed = active_item.inspected_curse and active_item.is_cursed
	icon_display.is_enchanted = active_item.inspected_resonance and active_item.enchantment_name != "Mundane / Inert"
	icon_display.is_stolen = active_item.inspected_visual and active_item.is_stolen
	icon_display.queue_redraw()

func _on_monocle_pressed() -> void:
	if not active_item: return
	var res = InspectionTool.use_monocle(active_item, GameState.daily_gazette)
	if EventBus:
		EventBus.sound_requested.emit(res.get("sfx", "monocle"))
		EventBus.item_inspected.emit("monocle", res)
	_update_notebook()

func _on_tuning_fork_pressed() -> void:
	if not active_item: return
	var res = InspectionTool.use_tuning_fork(active_item)
	if EventBus:
		EventBus.sound_requested.emit(res.get("sfx", "fork_chime"))
		EventBus.item_inspected.emit("tuning_fork", res)
	_update_notebook()

func _on_litmus_pressed() -> void:
	if not active_item: return
	var res = InspectionTool.use_litmus_salt(active_item)
	if EventBus:
		EventBus.sound_requested.emit(res.get("sfx", "smoke_clean"))
		EventBus.item_inspected.emit("litmus_salt", res)
	_update_notebook()

func _on_scale_pressed() -> void:
	if not active_item: return
	var res = InspectionTool.use_balance_scale(active_item)
	if EventBus:
		EventBus.sound_requested.emit(res.get("sfx", "scale_clunk"))
		EventBus.item_inspected.emit("balance_scale", res)
	_update_notebook()

func _on_back_pressed() -> void:
	visible = false
