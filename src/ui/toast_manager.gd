class_name ToastManager
extends Control

var toast_container: VBoxContainer

func _ready() -> void:
	mouse_filter = MOUSE_FILTER_IGNORE
	toast_container = VBoxContainer.new()
	toast_container.mouse_filter = MOUSE_FILTER_IGNORE
	toast_container.set_anchors_preset(PRESET_TOP_RIGHT)
	toast_container.position = Vector2(-360, 70)
	toast_container.custom_minimum_size = Vector2(340, 200)
	add_child(toast_container)

	if EventBus:
		EventBus.toast_requested.connect(show_toast)

func show_toast(title: String, message: String, type: String = "info") -> void:
	var panel = PanelContainer.new()
	panel.mouse_filter = MOUSE_FILTER_IGNORE
	var style = StyleBoxFlat.new()
	style.corner_radius_bottom_left = 6
	style.corner_radius_bottom_right = 6
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.content_margin_bottom = 8
	style.content_margin_top = 8
	style.content_margin_left = 12
	style.content_margin_right = 12

	match type:
		"danger":
			style.bg_color = Color(0.55, 0.1, 0.1, 0.95)
			style.border_color = Color(0.9, 0.2, 0.2)
		"warning":
			style.bg_color = Color(0.55, 0.35, 0.05, 0.95)
			style.border_color = Color(0.95, 0.7, 0.1)
		"success":
			style.bg_color = Color(0.1, 0.45, 0.2, 0.95)
			style.border_color = Color(0.3, 0.85, 0.4)
		_: # info
			style.bg_color = Color(0.15, 0.18, 0.25, 0.95)
			style.border_color = Color(0.4, 0.6, 0.9)

	style.border_width_left = 3
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	panel.add_theme_stylebox_override("panel", style)

	var vbox = VBoxContainer.new()
	var lbl_title = Label.new()
	lbl_title.text = title
	lbl_title.add_theme_font_size_override("font_size", 14)
	lbl_title.add_theme_color_override("font_color", Color(1.0, 0.95, 0.8))
	vbox.add_child(lbl_title)

	var lbl_msg = Label.new()
	lbl_msg.text = message
	lbl_msg.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl_msg.add_theme_font_size_override("font_size", 12)
	lbl_msg.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
	vbox.add_child(lbl_msg)

	panel.add_child(vbox)
	toast_container.add_child(panel)

	# Auto fade-out after 3.5 seconds
	var tween = create_tween()
	tween.tween_interval(3.0)
	tween.tween_property(panel, "modulate:a", 0.0, 0.5)
	tween.tween_callback(panel.queue_free)
