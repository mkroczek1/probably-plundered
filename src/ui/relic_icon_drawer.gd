class_name RelicIconDrawer
extends Control

@export var icon_key: String = "dagger" # dagger, sword, chalice, ring, tome, amulet, skull, potion
@export var is_cursed: bool = false
@export var is_enchanted: bool = false
@export var is_stolen: bool = false
@export var is_counterfeit: bool = false

func _draw() -> void:
	var rect = Rect2(Vector2.ZERO, size)
	var center = rect.size * 0.5
	var min_dim = min(rect.size.x, rect.size.y)
	var scale_factor = min_dim / 80.0

	# Dark velvet background slot
	draw_rect(rect, Color(0.10, 0.08, 0.07), true)
	draw_rect(rect, Color(0.35, 0.25, 0.18), false, 2.0)

	# Magic or Curse Glow
	if is_cursed:
		draw_circle(center, 28 * scale_factor, Color(0.65, 0.10, 0.85, 0.25))
	elif is_enchanted:
		draw_circle(center, 28 * scale_factor, Color(0.20, 0.70, 0.95, 0.25))

	match icon_key:
		"dagger":
			_draw_dagger(center, scale_factor)
		"sword":
			_draw_sword(center, scale_factor)
		"ring":
			_draw_ring(center, scale_factor)
		"amulet":
			_draw_amulet(center, scale_factor)
		"tome":
			_draw_tome(center, scale_factor)
		"chalice":
			_draw_chalice(center, scale_factor)
		"skull":
			_draw_skull(center, scale_factor)
		_:
			_draw_dagger(center, scale_factor)

	# Badges
	if is_stolen:
		# Hot warning mark
		draw_circle(center + Vector2(22, -22) * scale_factor, 8 * scale_factor, Color(0.85, 0.15, 0.15))
		draw_line(center + Vector2(22, -26) * scale_factor, center + Vector2(22, -20) * scale_factor, Color.WHITE, 2.0 * scale_factor)
		draw_circle(center + Vector2(22, -17) * scale_factor, 1.5 * scale_factor, Color.WHITE)

	if is_cursed:
		# Curse purple dot
		draw_circle(center + Vector2(-22, -22) * scale_factor, 7 * scale_factor, Color(0.6, 0.1, 0.8))

func _draw_dagger(center: Vector2, s: float) -> void:
	# Blade
	draw_colored_polygon([
		center + Vector2(0, -28) * s,
		center + Vector2(6, 6) * s,
		center + Vector2(-6, 6) * s
	], Color(0.85, 0.88, 0.92))
	# Fuller / Ridge
	draw_line(center + Vector2(0, -26) * s, center + Vector2(0, 6) * s, Color(0.55, 0.6, 0.65), 1.5 * s)
	# Crossguard
	draw_line(center + Vector2(-14, 6) * s, center + Vector2(14, 6) * s, Color(0.85, 0.65, 0.2), 4.0 * s)
	# Grip
	draw_line(center + Vector2(0, 7) * s, center + Vector2(0, 22) * s, Color(0.35, 0.2, 0.15), 4.0 * s)
	# Pommel
	draw_circle(center + Vector2(0, 24) * s, 4.0 * s, Color(0.85, 0.65, 0.2))

func _draw_sword(center: Vector2, s: float) -> void:
	# Long Blade
	draw_colored_polygon([
		center + Vector2(0, -32) * s,
		center + Vector2(8, 8) * s,
		center + Vector2(-8, 8) * s
	], Color(0.80, 0.85, 0.90))
	draw_line(center + Vector2(0, -30) * s, center + Vector2(0, 8) * s, Color(0.5, 0.55, 0.6), 2.0 * s)
	# Curved Guard
	draw_arc(center + Vector2(0, 8) * s, 16 * s, 0.2, 2.9, 10, Color(0.9, 0.7, 0.2), 4.0 * s)
	# Hilt
	draw_line(center + Vector2(0, 10) * s, center + Vector2(0, 26) * s, Color(0.2, 0.15, 0.12), 4.5 * s)
	draw_circle(center + Vector2(0, 28) * s, 5.0 * s, Color(0.9, 0.7, 0.2))

func _draw_ring(center: Vector2, s: float) -> void:
	# Gold Band
	draw_arc(center + Vector2(0, 4) * s, 18 * s, 0, TAU, 24, Color(0.95, 0.75, 0.2), 6.0 * s)
	# Giant Gemstone mount
	draw_circle(center + Vector2(0, -14) * s, 10 * s, Color(0.8, 0.15, 0.25))
	draw_arc(center + Vector2(0, -14) * s, 10 * s, 0, TAU, 16, Color(0.95, 0.85, 0.4), 2.0 * s)
	draw_circle(center + Vector2(-3, -17) * s, 2.5 * s, Color(1.0, 0.8, 0.85))

func _draw_amulet(center: Vector2, s: float) -> void:
	# Chain
	draw_arc(center + Vector2(0, -15) * s, 22 * s, 0.4, 2.7, 16, Color(0.8, 0.65, 0.2), 2.5 * s)
	# Medallion
	draw_circle(center + Vector2(0, 8) * s, 18 * s, Color(0.85, 0.70, 0.25))
	draw_circle(center + Vector2(0, 8) * s, 14 * s, Color(0.15, 0.2, 0.35))
	# Inner glowing gem
	draw_circle(center + Vector2(0, 8) * s, 8 * s, Color(0.2, 0.75, 0.95))

func _draw_tome(center: Vector2, s: float) -> void:
	# Leather Book cover
	draw_colored_polygon([
		center + Vector2(-20, -26) * s, center + Vector2(20, -26) * s,
		center + Vector2(24, 26) * s, center + Vector2(-16, 26) * s
	], Color(0.45, 0.15, 0.15))
	# Pages edge
	draw_colored_polygon([
		center + Vector2(16, -24) * s, center + Vector2(22, -24) * s,
		center + Vector2(26, 24) * s, center + Vector2(20, 24) * s
	], Color(0.92, 0.88, 0.78))
	# Arcane clasp & crest
	draw_circle(center + Vector2(2, 0) * s, 7 * s, Color(0.85, 0.75, 0.3))
	draw_line(center + Vector2(-18, -26) * s, center + Vector2(-14, 26) * s, Color(0.7, 0.55, 0.2), 3.0 * s)

func _draw_chalice(center: Vector2, s: float) -> void:
	# Cup
	draw_colored_polygon([
		center + Vector2(-18, -22) * s, center + Vector2(18, -22) * s,
		center + Vector2(14, 2) * s, center + Vector2(0, 10) * s,
		center + Vector2(-14, 2) * s
	], Color(0.9, 0.75, 0.25))
	# Wine / Blood
	draw_arc(center + Vector2(0, -18) * s, 14 * s, 0.3, 2.8, 12, Color(0.6, 0.05, 0.15), 5.0 * s)
	# Stem
	draw_line(center + Vector2(0, 10) * s, center + Vector2(0, 22) * s, Color(0.8, 0.65, 0.2), 5.0 * s)
	# Base
	draw_colored_polygon([
		center + Vector2(-16, 26) * s, center + Vector2(16, 26) * s,
		center + Vector2(0, 22) * s
	], Color(0.9, 0.75, 0.25))

func _draw_skull(center: Vector2, s: float) -> void:
	# Cranium
	draw_circle(center + Vector2(0, -6) * s, 20 * s, Color(0.88, 0.85, 0.78))
	# Jaw
	draw_colored_polygon([
		center + Vector2(-12, 10) * s, center + Vector2(12, 10) * s,
		center + Vector2(8, 22) * s, center + Vector2(-8, 22) * s
	], Color(0.82, 0.78, 0.72))
	# Eye sockets
	draw_circle(center + Vector2(-7, -4) * s, 5 * s, Color(0.12, 0.08, 0.08))
	draw_circle(center + Vector2(7, -4) * s, 5 * s, Color(0.12, 0.08, 0.08))
	# Teeth marks
	draw_line(center + Vector2(-6, 16) * s, center + Vector2(6, 16) * s, Color(0.2, 0.15, 0.15), 1.5 * s)
