class_name EventBusClass
extends Node

# Phase & Time Signals
signal phase_changed(new_phase: String)
signal day_advanced(day_number: int)

# Economy & Status Signals
signal gold_changed(new_gold: int, delta: int)
signal debt_changed(new_debt: int, delta: int)
signal heat_changed(new_heat: int, delta: int)
signal faction_rep_changed(faction: String, new_rep: int, delta: int)

# Customer & Transaction Signals
signal customer_arrived(customer)
signal customer_departed(customer, deal_struck: bool)
signal item_selected_for_inspection(item)
signal item_inspected(tool_name: String, result: Dictionary)
signal item_purchased(item, price: int)
signal item_sold(item, price: int)

# Backroom & Laundering Signals
signal item_laundered(item, operation: String)
signal cellar_updated()

# Crisis & Raids
signal inquisition_raid_triggered()
signal inquisition_raid_resolved(success: bool, outcome_data: Dictionary)

# Game Outcome Signals
signal game_over(condition_id: String, victory: bool, title: String, message: String)

# UI & Feedback Signals
signal toast_requested(title: String, message: String, type: String)
signal sound_requested(sfx_name: String)
