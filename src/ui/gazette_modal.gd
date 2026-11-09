class_name GazetteModal
extends Control

@onready var lbl_date: Label = $Panel/VBox/Header/LblDate
@onready var lbl_headline: Label = $Panel/VBox/LblHeadline
@onready var txt_market: RichTextLabel = $Panel/VBox/HBoxContent/VBoxNews/TxtMarket
@onready var txt_bounty: RichTextLabel = $Panel/VBox/HBoxContent/VBoxNews/TxtBounty
@onready var txt_edict: RichTextLabel = $Panel/VBox/HBoxContent/VBoxNews/TxtEdict
@onready var txt_ledger: RichTextLabel = $Panel/VBox/HBoxContent/VBoxLedger/TxtLedger
@onready var btn_open_shop: Button = $Panel/VBox/BtnOpenShop

func _ready() -> void:
	btn_open_shop.pressed.connect(_on_open_shop_pressed)
	if EventBus:
		EventBus.phase_changed.connect(_on_phase_changed)

func _on_phase_changed(phase: String) -> void:
	if phase == GameState.PHASE_MORNING:
		populate_gazette()
		visible = true
	else:
		visible = false

func populate_gazette() -> void:
	var g = GameState.daily_gazette
	if g.is_empty(): return

	lbl_date.text = "OAKHAVEN GAZETTE - " + g.get("date_str", "Day 1")
	lbl_headline.text = "📰 " + g.get("headline", "RELIC RUSH IN THE MAW!")

	var bb_market = "[b]MARKET DEMAND & COMMERCE[/b]\n"
	bb_market += "• High Demand: [color=#4ade80]" + g.get("favored_category", "weapon").capitalize() + " (+40% value)[/color]\n"
	bb_market += "• Slumping Price: [color=#f87171]" + g.get("disfavored_category", "armor").capitalize() + " (-30% value)[/color]\n"
	bb_market += "• Underworld Whisper: [color=#fbbf24]" + g.get("underworld_rumor", "") + "[/color]"
	txt_market.bbcode_text = bb_market

	var b = g.get("stolen_bounty", {})
	var bb_bounty = "[b]🚨 POLICE BLOTTER: STOLEN RELIC NOTICE[/b]\n"
	bb_bounty += "[color=#ef4444]" + b.get("item_name", "Royal Heirloom") + "[/color] stolen from [color=#fef08a]" + b.get("victim", "") + "[/color]!\n"
	bb_bounty += "Reward for recovery: [color=#fbbf24]" + str(b.get("reward", 800)) + " Gold[/color]\n"
	bb_bounty += "[i]" + b.get("description", "") + "[/i]"
	txt_bounty.bbcode_text = bb_bounty

	var e = g.get("edict", {})
	var bb_edict = "[b]☀️ SUN SYNOD INQUISITION EDICT[/b]\n"
	bb_edict += "[color=#fbbf24]" + e.get("name", "Standard Patrol") + "[/color]\n"
	bb_edict += e.get("desc", "Standard vigilance in effect.")
	txt_edict.bbcode_text = bb_edict

	# Morning Ledger
	var overhead = LoanManager.get_daily_overhead(GameState.current_day)
	var next_due_day = LoanManager.get_next_installment_day(GameState.current_day)
	var next_due_amt = LoanManager.get_installment_due(next_due_day)
	var days_left = next_due_day - GameState.current_day

	var bb_ledger = "[b]DAILY PAWNSHOP LEDGER[/b]\n\n"
	bb_ledger += "Current Treasury: [color=#fbbf24]" + str(GameState.gold) + " Gold[/color]\n"
	bb_ledger += "Daily Overhead: [color=#f87171]-" + str(overhead) + " G[/color] (" + ("Paid" if GameState.daily_overhead_paid_today else "DEFICIT!") + ")\n"
	bb_ledger += "Remaining Syndicate Loan: [color=#ef4444]" + str(GameState.total_debt) + " Gold[/color]\n"
	bb_ledger += "Next Installment: [color=#fbbf24]" + str(next_due_amt) + "G[/color] in " + str(days_left) + " days (Day " + str(next_due_day) + ")\n"
	bb_ledger += "Missed Payments: " + ("None" if GameState.consecutive_missed_payments == 0 else "[color=#ef4444]" + str(GameState.consecutive_missed_payments) + " / 2 (WARNING)[/color]") + "\n"
	bb_ledger += "Current Shop Heat: " + str(GameState.heat) + "%\n"
	txt_ledger.bbcode_text = bb_ledger

func _on_open_shop_pressed() -> void:
	visible = false
	GameState.advance_to_counter_rush()
