class_name PortraitDrawer
extends Control

@export var portrait_key: String = "rogue"
@export var expression: String = "neutral" # neutral, happy, angry, embarrassed, panicked

func _draw() -> void:
	var rect = Rect2(Vector2.ZERO, size)
	var center = rect.size * 0.5
	
	# Background frame
	draw_rect(rect, Color(0.12, 0.09, 0.08), true)
	draw_rect(rect, Color(0.78, 0.60, 0.22), false, 3.0)

	match portrait_key:
		"mage":
			_draw_mage(center)
		"rogue":
			_draw_rogue(center)
		"paladin":
			_draw_paladin(center)
		"inquisitor":
			_draw_inquisitor(center)
		"collector":
			_draw_collector(center)
		_:
			_draw_scavenger(center)

	# Expression overlays
	if expression == "embarrassed":
		# Blushing cheeks
		draw_circle(center + Vector2(-28, 12), 10, Color(0.9, 0.3, 0.4, 0.45))
		draw_circle(center + Vector2(28, 12), 10, Color(0.9, 0.3, 0.4, 0.45))
	elif expression == "panicked":
		# Sweat drops
		draw_circle(center + Vector2(36, -30), 5, Color(0.3, 0.7, 1.0, 0.8))
		draw_line(center + Vector2(36, -30), center + Vector2(36, -38), Color(0.3, 0.7, 1.0, 0.8), 2.0)
	elif expression == "angry":
		# Vein mark
		draw_line(center + Vector2(-32, -35), center + Vector2(-24, -35), Color(0.9, 0.1, 0.1), 2.5)
		draw_line(center + Vector2(-28, -39), center + Vector2(-28, -31), Color(0.9, 0.1, 0.1), 2.5)

func _draw_mage(center: Vector2) -> void:
	# Dark violet cowl
	draw_circle(center + Vector2(0, -10), 45, Color(0.22, 0.10, 0.35))
	# Face
	draw_circle(center + Vector2(0, 0), 32, Color(0.95, 0.82, 0.72))
	# Hair bangs
	draw_colored_polygon([
		center + Vector2(-32, -18), center + Vector2(-15, 6),
		center + Vector2(0, -10), center + Vector2(18, 8),
		center + Vector2(32, -18), center + Vector2(0, -32)
	], Color(0.15, 0.08, 0.25))
	# Occult Eyepatch over right eye
	draw_circle(center + Vector2(14, -2), 9, Color(0.1, 0.1, 0.12))
	draw_line(center + Vector2(6, -6), center + Vector2(22, 2), Color(0.8, 0.2, 0.2), 2.0)
	# Glowing Left Eye
	draw_circle(center + Vector2(-14, -2), 6, Color(0.95, 0.2, 0.3))
	draw_circle(center + Vector2(-14, -2), 2, Color(1.0, 0.9, 0.9))
	# Smirk
	draw_arc(center + Vector2(0, 16), 10, 0.2, 2.2, 8, Color(0.3, 0.1, 0.1), 2.0)
	# Cowl cloak shoulders
	draw_colored_polygon([
		center + Vector2(-55, 60), center + Vector2(-30, 25),
		center + Vector2(30, 25), center + Vector2(55, 60)
	], Color(0.18, 0.08, 0.30))

func _draw_rogue(center: Vector2) -> void:
	# Leather Hood
	draw_circle(center + Vector2(0, -10), 46, Color(0.20, 0.22, 0.20))
	# Face
	draw_circle(center + Vector2(0, 2), 30, Color(0.92, 0.80, 0.70))
	# Hair
	draw_colored_polygon([
		center + Vector2(-30, -15), center + Vector2(-10, 2),
		center + Vector2(5, -12), center + Vector2(20, 4),
		center + Vector2(30, -15), center + Vector2(0, -28)
	], Color(0.32, 0.20, 0.12))
	# Eyes
	draw_circle(center + Vector2(-13, 0), 4, Color(0.2, 0.5, 0.3))
	draw_circle(center + Vector2(13, 0), 4, Color(0.2, 0.5, 0.3))
	# Cheek bandage
	draw_line(center + Vector2(-22, 12), center + Vector2(-14, 16), Color(0.9, 0.88, 0.8), 4.0)
	# Sly smirk
	draw_arc(center + Vector2(2, 16), 8, 0.1, 2.0, 6, Color(0.25, 0.1, 0.1), 2.0)
	# Leather mantle
	draw_colored_polygon([
		center + Vector2(-55, 60), center + Vector2(-28, 25),
		center + Vector2(28, 25), center + Vector2(55, 60)
	], Color(0.15, 0.16, 0.14))

func _draw_paladin(center: Vector2) -> void:
	# Golden hair
	draw_circle(center + Vector2(0, -8), 44, Color(0.96, 0.82, 0.35))
	# Face
	draw_circle(center + Vector2(0, 4), 30, Color(0.98, 0.86, 0.78))
	# Silver circlet / tiara
	draw_line(center + Vector2(-30, -14), center + Vector2(30, -14), Color(0.85, 0.90, 0.95), 4.0)
	draw_circle(center + Vector2(0, -16), 5, Color(0.2, 0.6, 0.95))
	# Blue proud eyes
	draw_circle(center + Vector2(-13, 2), 5, Color(0.15, 0.45, 0.85))
	draw_circle(center + Vector2(13, 2), 5, Color(0.15, 0.45, 0.85))
	# Pout / Small mouth
	draw_line(center + Vector2(-6, 20), center + Vector2(6, 20), Color(0.6, 0.2, 0.25), 2.5)
	# Silver armor gorget
	draw_colored_polygon([
		center + Vector2(-55, 60), center + Vector2(-25, 28),
		center + Vector2(25, 28), center + Vector2(55, 60)
	], Color(0.75, 0.80, 0.88))
	# Gold filigree trim
	draw_line(center + Vector2(-25, 28), center + Vector2(25, 28), Color(0.95, 0.75, 0.2), 3.0)

func _draw_inquisitor(center: Vector2) -> void:
	# Wide-brim witch hunter hat
	draw_colored_polygon([
		center + Vector2(-60, -12), center + Vector2(60, -12),
		center + Vector2(32, -45), center + Vector2(-32, -45)
	], Color(0.12, 0.10, 0.10))
	draw_line(center + Vector2(-65, -12), center + Vector2(65, -12), Color(0.12, 0.10, 0.10), 6.0)
	# Sun brooch on hat
	draw_circle(center + Vector2(0, -28), 7, Color(0.95, 0.75, 0.2))
	# Shaded Face
	draw_circle(center + Vector2(0, 10), 28, Color(0.88, 0.76, 0.68))
	# Piercing eyes
	draw_line(center + Vector2(-18, 6), center + Vector2(-8, 8), Color(0.8, 0.6, 0.1), 3.0)
	draw_line(center + Vector2(8, 8), center + Vector2(18, 6), Color(0.8, 0.6, 0.1), 3.0)
	# Thin severe mouth
	draw_line(center + Vector2(-10, 24), center + Vector2(10, 24), Color(0.3, 0.15, 0.15), 2.0)
	# High stiff collar & coat
	draw_colored_polygon([
		center + Vector2(-55, 60), center + Vector2(-25, 30),
		center + Vector2(25, 30), center + Vector2(55, 60)
	], Color(0.45, 0.08, 0.08))

func _draw_collector(center: Vector2) -> void:
	# Aristocrat wig / hair
	draw_circle(center + Vector2(0, -6), 42, Color(0.85, 0.85, 0.88))
	# Face
	draw_circle(center + Vector2(0, 6), 30, Color(0.95, 0.84, 0.76))
	# Gold Monocle on right eye
	draw_circle(center + Vector2(13, 4), 9, Color(0.2, 0.8, 0.9, 0.3))
	draw_arc(center + Vector2(13, 4), 9, 0, TAU, 16, Color(0.95, 0.75, 0.1), 2.5)
	draw_line(center + Vector2(22, 6), center + Vector2(32, 28), Color(0.95, 0.75, 0.1), 1.5)
	# Left eye
	draw_circle(center + Vector2(-13, 4), 4, Color(0.25, 0.35, 0.45))
	# Aristocratic mustache
	draw_arc(center + Vector2(-6, 20), 8, 3.14, 4.8, 6, Color(0.7, 0.7, 0.75), 3.0)
	draw_arc(center + Vector2(6, 20), 8, 4.6, 6.28, 6, Color(0.7, 0.7, 0.75), 3.0)
	# Velvet coat & ruff collar
	draw_colored_polygon([
		center + Vector2(-55, 60), center + Vector2(-25, 32),
		center + Vector2(25, 32), center + Vector2(55, 60)
	], Color(0.12, 0.18, 0.38))
	draw_circle(center + Vector2(0, 34), 12, Color(0.95, 0.95, 0.95))

func _draw_scavenger(center: Vector2) -> void:
	# Rugged hood
	draw_circle(center + Vector2(0, -10), 45, Color(0.28, 0.22, 0.18))
	# Face
	draw_circle(center + Vector2(0, 4), 30, Color(0.85, 0.70, 0.58))
	# Scar
	draw_line(center + Vector2(-14, -8), center + Vector2(-6, 12), Color(0.65, 0.35, 0.35), 2.0)
	# Rugged Beard
	draw_colored_polygon([
		center + Vector2(-22, 10), center + Vector2(22, 10),
		center + Vector2(16, 32), center + Vector2(0, 38),
		center + Vector2(-16, 32)
	], Color(0.25, 0.16, 0.10))
	# Weary eyes
	draw_circle(center + Vector2(-12, 2), 4, Color(0.2, 0.15, 0.15))
	draw_circle(center + Vector2(12, 2), 4, Color(0.2, 0.15, 0.15))
	# Heavy wool coat
	draw_colored_polygon([
		center + Vector2(-55, 60), center + Vector2(-25, 32),
		center + Vector2(25, 32), center + Vector2(55, 60)
	], Color(0.35, 0.28, 0.22))
