extends Control

var vector := Vector2.ZERO

func _draw() -> void:
    var center := size / 2.0
    draw_circle(center, 61.0, Color(0.04, 0.08, 0.06, 0.42))
    draw_arc(center, 61.0, 0.0, TAU, 64, Color(1, 1, 1, 0.65), 2.0)
    draw_circle(center + vector * 42.0, 23.0, Color(1, 1, 1, 0.76))
