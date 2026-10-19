extends Node2D

const WORLD_SIZE := Vector2(2000, 1500)
var buildings: Array[Dictionary] = []
var cash := 250
var joystick_origin := Vector2.ZERO
var joystick_vector := Vector2.ZERO
var joystick_active := false
var is_running := false
var player: CharacterBody2D
var hud: Control
var hud_layer: CanvasLayer
var cash_label: Label
var message_label: Label
var online_button: Button
var interact_button: Button
var run_button: Button
var joystick: Control

func _ready() -> void:
    player = get_node("Player")
    buildings = [
        {"rect": Rect2(150, 130, 190, 130), "color": Color("d98d61"), "name": "مقهى النخلة", "kind": "shop"},
        {"rect": Rect2(390, 110, 210, 150), "color": Color("d5c28e"), "name": "متجر المدينة", "kind": "shop"},
        {"rect": Rect2(850, 130, 200, 150), "color": Color("bd7b7b"), "name": "مركز الشرطة", "kind": "building"},
        {"rect": Rect2(1280, 120, 230, 155), "color": Color("d9b56d"), "name": "بيت كبير", "kind": "building"},
        {"rect": Rect2(140, 500, 220, 160), "color": Color("9eaecc"), "name": "مستشفى المدينة", "kind": "building"},
        {"rect": Rect2(650, 500, 245, 175), "color": Color("d6a17e"), "name": "عمارة سكنية", "kind": "building"},
        {"rect": Rect2(1160, 500, 235, 165), "color": Color("b4c88c"), "name": "ورشة السيارات", "kind": "building"},
        {"rect": Rect2(150, 980, 240, 160), "color": Color("d6c5a4"), "name": "مطعم البلد", "kind": "shop"},
        {"rect": Rect2(570, 970, 195, 150), "color": Color("c69ab7"), "name": "مبنى المكاتب", "kind": "building"},
        {"rect": Rect2(1030, 970, 255, 165), "color": Color("d6b26f"), "name": "السوق الكبير", "kind": "shop"}
    ]
    _build_world()
    _build_hud()
    queue_redraw()

func _build_world() -> void:
    for b in buildings:
        var body := StaticBody2D.new()
        body.position = b.rect.position + b.rect.size / 2.0
        body.collision_layer = 1
        body.collision_mask = 1
        var shape := CollisionShape2D.new()
        var rectangle := RectangleShape2D.new()
        rectangle.size = b.rect.size
        shape.shape = rectangle
        body.add_child(shape)
        add_child(body)

func _build_hud() -> void:
    hud_layer = CanvasLayer.new()
    add_child(hud_layer)
    hud = Control.new()
    hud.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    hud.mouse_filter = Control.MOUSE_FILTER_IGNORE
    var top := HBoxContainer.new()
    top.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
    top.offset_left = 12
    top.offset_top = 10
    top.offset_right = -12
    top.add_theme_constant_override("separation", 12)
    hud.add_child(top)
    cash_label = Label.new()
    cash_label.text = "💵 %d" % cash
    cash_label.add_theme_font_size_override("font_size", 20)
    top.add_child(cash_label)
    var spacer := Control.new()
    spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    top.add_child(spacer)
    var title := Label.new()
    title.text = "يلا سيتي · نسخة تجريبية"
    title.add_theme_font_size_override("font_size", 18)
    top.add_child(title)
    message_label = Label.new()
    message_label.text = "حرّك عصا التحكم للمشي · اقترب من مبنى واضغط تفاعل"
    message_label.position = Vector2(16, 48)
    message_label.add_theme_font_size_override("font_size", 14)
    hud.add_child(message_label)
    joystick = Control.new()
    joystick.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
    joystick.position = Vector2(22, -148)
    joystick.size = Vector2(128, 128)
    joystick.mouse_filter = Control.MOUSE_FILTER_STOP
    joystick.set_script(load("res://scripts/joystick_visual.gd"))
    joystick.gui_input.connect(_on_joystick_input)
    hud.add_child(joystick)
    var action_box := HBoxContainer.new()
    action_box.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
    action_box.position = Vector2(-245, -95)
    action_box.size = Vector2(230, 75)
    action_box.add_theme_constant_override("separation", 12)
    hud.add_child(action_box)
    run_button = Button.new()
    run_button.text = "جري"
    run_button.custom_minimum_size = Vector2(95, 65)
    run_button.button_down.connect(func(): is_running = true)
    run_button.button_up.connect(func(): is_running = false)
    action_box.add_child(run_button)
    interact_button = Button.new()
    interact_button.text = "تفاعل"
    interact_button.custom_minimum_size = Vector2(105, 65)
    interact_button.pressed.connect(_interact)
    action_box.add_child(interact_button)
    online_button = Button.new()
    online_button.text = "أونلاين تجريبي"
    online_button.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
    online_button.offset_left = -170
    online_button.offset_top = 50
    online_button.offset_right = -12
    online_button.offset_bottom = 86
    online_button.pressed.connect(func(): _say("الأونلاين الحقيقي يحتاج إعداد خادم وربط لاعبين؛ هذا الزر توضيحي حاليًا."))
    hud.add_child(online_button)
    hud_layer.add_child(hud)

func _on_joystick_input(event: InputEvent) -> void:
    if event is InputEventScreenTouch:
        joystick_active = event.pressed
        if joystick_active:
            _update_joystick(event.position)
        else:
            joystick_vector = Vector2.ZERO
            player.touch_direction = Vector2.ZERO
            joystick.queue_redraw()
    elif event is InputEventScreenDrag and joystick_active:
        _update_joystick(event.position)
    elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
        joystick_active = event.pressed
        if not joystick_active:
            joystick_vector = Vector2.ZERO
            player.touch_direction = Vector2.ZERO
        else:
            _update_joystick(event.position)
    elif event is InputEventMouseMotion and joystick_active:
        _update_joystick(event.position)

func _update_joystick(pos: Vector2) -> void:
    var center := joystick.size / 2.0
    var delta := pos - center
    joystick_vector = delta.limit_length(42.0) / 42.0
    player.touch_direction = joystick_vector
    joystick.set("vector", joystick_vector)
    joystick.queue_redraw()

func _process(_delta: float) -> void:
    queue_redraw()
    if joystick:
        joystick.queue_redraw()

func _draw() -> void:
    draw_rect(Rect2(Vector2.ZERO, WORLD_SIZE), Color("80ad6d"))
    for x in range(0, int(WORLD_SIZE.x), 90):
        for y in range(0, int(WORLD_SIZE.y), 90):
            if (x * 3 + y * 7) % 5 == 0:
                draw_rect(Rect2(x + 7, y + 13, 38, 24), Color("76a565"))
    for y in [390, 830]:
        draw_rect(Rect2(0, y, WORLD_SIZE.x, 115), Color("555b5e"))
        for x in range(0, int(WORLD_SIZE.x), 42):
            draw_rect(Rect2(x, y + 55, 22, 3), Color("e8dca2"))
    for x in [410, 990]:
        draw_rect(Rect2(x, 0, 105, WORLD_SIZE.y), Color("555b5e"))
        for y in range(0, int(WORLD_SIZE.y), 42):
            draw_rect(Rect2(x + 51, y, 3, 22), Color("e8dca2"))
    for i in range(55):
        var tx := float(35 + (i * 197) % 1900)
        var ty := float(30 + (i * 131) % 1400)
        draw_circle(Vector2(tx + 3, ty + 5), 12 + i % 6, Color("4e7445"))
        draw_circle(Vector2(tx, ty), 12 + i % 6, Color("3d8b52"))
        draw_circle(Vector2(tx - 3, ty - 3), 7 + i % 3, Color("64a961"))
    for b in buildings:
        var r: Rect2 = b.rect
        draw_rect(Rect2(r.position + Vector2(7, 9), r.size), Color(0, 0, 0, 0.16))
        draw_rect(r, b.color)
        draw_rect(Rect2(r.position + Vector2(9, 9), Vector2(r.size.x - 18, 16)), Color("f0e2bd"))
        for wx in range(int(r.position.x + 18), int(r.end.x - 12), 38):
            for wy in range(int(r.position.y + 39), int(r.end.y - 30), 36):
                draw_rect(Rect2(wx, wy, 20, 18), Color("9ed4e1"))
        draw_rect(Rect2(r.position.x + r.size.x / 2 - 13, r.end.y - 37, 26, 37), Color("755344"))
        draw_string(ThemeDB.fallback_font, Vector2(r.position.x, r.position.y - 8), b.name, HORIZONTAL_ALIGNMENT_LEFT, r.size.x + 30, 16, Color.WHITE)
    draw_rect(Rect2(1430, 600, 260, 220), Color("b6c889"))
    draw_rect(Rect2(1450, 620, 220, 180), Color("658e4f"))
    draw_rect(Rect2(1553, 620, 14, 180), Color("d9cba3"))
    draw_rect(Rect2(1450, 700, 220, 14), Color("d9cba3"))

func _interact() -> void:
    var nearest: Dictionary = {}
    var nearest_distance := 1.0e20
    for b in buildings:
        var center: Vector2 = b.rect.position + b.rect.size / 2.0
        var distance := player.global_position.distance_to(center)
        if distance < nearest_distance:
            nearest_distance = distance
            nearest = b
    if nearest_distance < 145.0:
        if nearest.kind == "shop":
            cash += 25
            cash_label.text = "💵 %d" % cash
            _say("زرت %s وكسبت 25 جنيه!" % nearest.name)
        else:
            _say("أنت قريب من %s · الدخول للمباني قادم" % nearest.name)
    else:
        cash += 5
        cash_label.text = "💵 %d" % cash
        _say("جمعت 5 جنيه من الشارع!")

func _say(text: String) -> void:
    message_label.text = text
