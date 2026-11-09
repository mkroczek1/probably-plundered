class_name HUDController
extends PanelContainer

@onready var lbl_day: Label = $HBox/VBoxDay/LblDay
@onready var lbl_phase: Label = $HBox/VBoxDay/LblPhase
@onready var lbl_gold: Label = $HBox/VBoxEcon/LblGold
@onready var lbl_debt: Label = $HBox/VBoxEcon/LblDebt
@onready var bar_heat: ProgressBar = $HBox/VBoxHeat/BarHeat
@onready var lbl_heat: Label = $HBox/VBoxHeat/LblHeat
@onready var lbl_factions: Label = $HBox/VBoxFactions/LblFactions
@onready var lbl_warning: Label = $HBox/LblWarning

func _ready() -> void:
	if EventBus:
		EventBus.gold_changed.connect(_on_gold_changed)
		EventBus.debt_changed.connect(_on_debt_changed)
		EventBus.heat_changed.connect(_on_heat_changed)
		EventBus.phase_changed.connect(_on_phase_changed)
		EventBus.day_advanced.connect(_on_day_advanced)
		EventBus.faction_rep_changed.connect(_on_faction_changed)
	update_all()

func update_all() -> void:
	if not GameState:
		return
	lbl_day.text = "DAY " + str(GameState.current_day) + " / " + str(GameState.max_days)
	
	var phase_name = "Morning Setup"
	match GameState.current_phase:
		GameState.PHASE_COUNTER:
			phase_name = "Counter Rush"
		GameState.PHASE_NIGHT:
			phase_name = "Night Workshop"
	lbl_phase.text = "Phase: " + phase_name

	lbl_gold.text = "🪙 " + str(GameState.gold) + " Gold"
	
	var next_due_day = LoanManager.get_next_installment_day(GameState.current_day)
	var next_due_amt = LoanManager.get_installment_due(next_due_day)
	var days_left = next_due_day - GameState.current_day
	lbl_debt.text = "Debt: " + str(GameState.total_debt) + "G (Due D" + str(next_due_day) + ": " + str(next_due_amt) + "G in " + str(days_left) + "d)"

	bar_heat.value = GameState.heat
	lbl_heat.text = "Heat: " + str(GameState.heat) + "%"
	
	if GameState.heat >= 75:
		lbl_heat.text += " ⚠️ INQUISITION RAID RISK!"
		lbl_warning.text = "POLICE HEAT CRITICAL! Contraband will trigger sudden raids!"
		lbl_warning.visible = true
	elif GameState.foundation_rot > 30:
		lbl_warning.text = "Cellar foundation rotting from cursed relics! (" + str(GameState.foundation_rot) + "%)"
		lbl_warning.visible = true
	else:
		lbl_warning.visible = false

	var f = GameState.faction_reps
	lbl_factions.text = "☀️ Inq: %d | 🛡️ Gld: %d | 🗡️ Syn: %d | 👑 Ari: %d" % [
		f["Inquisition"], f["Guild"], f["Syndicate"], f["Aristocracy"]
	]

func _on_gold_changed(_g: int, _d: int) -> void: update_all()
func _on_debt_changed(_b: int, _d: int) -> void: update_all()
func _on_heat_changed(_h: int, _d: int) -> void: update_all()
func _on_phase_changed(_p: String) -> void: update_all()
func _on_day_advanced(_d: int) -> void: update_all()
func _on_faction_changed(_f: String, _r: int, _d: int) -> void: update_all()
