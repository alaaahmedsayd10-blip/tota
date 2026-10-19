extends CharacterBody2D

@export var walk_speed: float = 165.0
@export var run_speed: float = 245.0
var touch_direction: Vector2 = Vector2.ZERO
var running: bool = false

func _physics_process(_delta: float) -> void:
    var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
    if touch_direction.length() > 0.12:
        direction = touch_direction.normalized()
    velocity = direction * (run_speed if running or Input.is_action_pressed("run") else walk_speed)
    move_and_slide()
    global_position.x = clampf(global_position.x, 20.0, 1980.0)
    global_position.y = clampf(global_position.y, 20.0, 1480.0)
