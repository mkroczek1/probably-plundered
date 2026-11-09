class_name GameOverScreen
extends Control

@onready var lbl_header: Label = $Panel/VBox/LblHeader
@onready var lbl_title: Label = $Panel/VBox/LblTitle
@onready var txt_narrative: RichTextLabel = $Panel/VBox/TxtNarrative
@onready var lbl_stats: RichTextLabel = $Panel/VBox/LblStats
@onready var btn_restart: Button = $Panel/VBox/BtnRestart

func _ready() -> void:
	btn_restart.pressed.connect(_on_restart_pressed)
	if EventBus:
		EventBus.game_over.connect(show_game_over)

func show_game_over(condition_id: String, victory: bool, title_text: String, message_text: String) -> void:
	visible = true
	if victory:
		lbl_header.text = "🏆 VICTORY ACHIEVED! 🏆"
		lbl_header.add_theme_color_override("font_color", Color(0.95, 0.85, 0.2))
	else:
		lbl_header.text = "💀 THE RECKONING HAS COME - GAME OVER 💀"
		lbl_header.add_theme_color_override("font_color", Color(0.9, 0.2, 0.2))

	lbl_title.text = title_text
	txt_narrative.bbcode_text = message_text

	var f = GameState.faction_reps
	var stats = "[b]FINAL BROKER DOSSIER:[/b]\n"
	stats += "• Days Survived: %d / %d\n" % [GameState.current_day, GameState.max_days]
	stats += "• Final Treasury: %d Gold\n" % GameState.gold
	stats += "• Remaining Debt: %d Gold\n" % GameState.total_debt
	stats += "• Purified Relics Supplied: %d\n" % GameState.purified_relics_supplied
	stats += "• Celestial Diamonds Smuggled: %d / 5\n" % GameState.celestial_diamonds
	stats += "• Final Faction Standing: Inq: %d | Guild: %d | Syndicate: %d | Aristocracy: %d\n" % [
		f["Inquisition"], f["Guild"], f["Syndicate"], f["Aristocracy"]
	]
	stats += "• Final Shop Heat: %d%%" % GameState.heat
	lbl_stats.bbcode_text = stats

func _on_restart_pressed() -> void:
	visible = false
	GameState.start_new_game()
