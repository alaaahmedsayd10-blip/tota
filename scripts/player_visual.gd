extends Node2D

var walk_phase := 0.0
func _process(delta: float) -> void:
    if get_parent() is CharacterBody2D and (get_parent() as CharacterBody2D).velocity.length() > 5.0:
        walk_phase += delta * 12.0
    queue_redraw()

func _draw() -> void:
    var bob := sin(walk_phase) * 1.5 if get_parent() is CharacterBody2D and (get_parent() as CharacterBody2D).velocity.length() > 5.0 else 0.0
    draw_circle(Vector2(2, 9), 12.0, Color(0, 0, 0, 0.23))
    draw_rect(Rect2(-8, -1 + bob, 16, 18), Color("2867d7"))
    draw_rect(Rect2(-8, 14 + bob, 6, 9), Color("26364c"))
    draw_rect(Rect2(2, 14 + bob, 6, 9), Color("26364c"))
    draw_circle(Vector2(0, -8 + bob), 8, Color("f0bd91"))
    draw_rect(Rect2(-5, -10 + bob, 3, 3), Color.WHITE)
    draw_rect(Rect2(2, -10 + bob, 3, 3), Color.WHITE)
