class_name MainGameCoordinator
extends Control

@onready var hud: HUDController = $HUD
@onready var shop_counter_view: CounterUI = $ShopCounterView
@onready var backroom_workshop: WorkshopUI = $BackroomWorkshop
@onready var inspection_table: InspectionTableView = $InspectionTable
@onready var inquisition_raid: InquisitionRaidView = $InquisitionRaidEvent
@onready var gazette_modal: GazetteModal = $GazetteModal
@onready var game_over_screen: GameOverScreen = $GameOverScreen

func _ready() -> void:
	# Link inspection table reference to counter
	shop_counter_view.set_inspection_view(inspection_table)
	inspection_table.visible = false
	inquisition_raid.visible = false
	game_over_screen.visible = false

	if EventBus:
		EventBus.phase_changed.connect(_on_phase_changed)
	
	_on_phase_changed(GameState.current_phase)

func _on_phase_changed(phase: String) -> void:
	match phase:
		GameState.PHASE_MORNING:
			gazette_modal.visible = true
			shop_counter_view.visible = false
			backroom_workshop.visible = false
			inspection_table.visible = false
		GameState.PHASE_COUNTER:
			gazette_modal.visible = false
			shop_counter_view.visible = true
			backroom_workshop.visible = false
			inspection_table.visible = false
		GameState.PHASE_NIGHT:
			gazette_modal.visible = false
			shop_counter_view.visible = false
			backroom_workshop.visible = true
			inspection_table.visible = false
