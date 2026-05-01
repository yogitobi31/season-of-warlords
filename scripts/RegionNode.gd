extends Button
class_name RegionNode

signal region_clicked(region_id: String)

@export var region_id: String = ""
@export var region_name: String = ""
@export var owner_faction: int = 0
@export var adjacent_regions: Array = []

const REGION_SIZE := Vector2(160, 76)

var is_selected: bool = false
var is_attackable: bool = false
var is_rumor_target: bool = false
var danger_text: String = ""

func _ready() -> void:
	# MVP 단계에서는 Area2D보다 Button이 클릭 동작을 확인하기 훨씬 쉽습니다.
	# Godot 4.6에서 pressed 신호를 사용해 확실하게 클릭 이벤트를 받습니다.
	custom_minimum_size = REGION_SIZE
	size = REGION_SIZE
	focus_mode = Control.FOCUS_NONE
	mouse_filter = Control.MOUSE_FILTER_STOP
	if not pressed.is_connected(_on_pressed):
		pressed.connect(_on_pressed)
	update_visual()

func setup(id: String, display_name: String, faction_id: int, neighbors: Array) -> void:
	region_id = id
	region_name = display_name
	owner_faction = faction_id

	adjacent_regions.clear()
	for neighbor in neighbors:
		adjacent_regions.append(str(neighbor))

	update_visual()

func update_owner(faction_id: int) -> void:
	owner_faction = faction_id
	update_visual()

func set_selected(value: bool) -> void:
	is_selected = value
	update_visual()

func set_attackable(value: bool) -> void:
	is_attackable = value
	update_visual()

func set_region_meta(region_danger: String, rumor_target: bool) -> void:
	danger_text = region_danger
	is_rumor_target = rumor_target
	update_visual()

func update_visual() -> void:
	custom_minimum_size = REGION_SIZE
	size = REGION_SIZE

	var status_line: String = ""
	if is_rumor_target:
		status_line = "★소문"
	elif danger_text != "":
		status_line = "위험: %s" % danger_text
	else:
		status_line = ""

	text = region_name
	if status_line != "":
		text += "\n%s" % status_line

	var base_color: Color = Color.DIM_GRAY
	if typeof(GameState) != TYPE_NIL:
		base_color = GameState.FACTION_COLORS.get(owner_faction, Color.DIM_GRAY)

	var border_color: Color = Color(0.08, 0.08, 0.08)
	var border_width: int = 2
	if is_selected:
		border_color = Color(1.0, 0.95, 0.1)
		border_width = 6
	elif is_attackable:
		border_color = Color(1.0, 0.65, 0.0)
		border_width = 5

	if is_rumor_target:
		border_color = Color(1.0, 0.9, 0.2)
		if border_width < 4:
			border_width = 4

	if owner_faction == GameState.PLAYER_FACTION:
		base_color = Color(0.18, 0.35, 0.76)
	elif owner_faction == GameState.CRIMSON_DUCHY_FACTION:
		base_color = Color(0.7, 0.2, 0.2)
	elif owner_faction == GameState.GREEN_MARQUIS_FACTION:
		base_color = Color(0.24, 0.5, 0.24)

	if danger_text == "이벤트":
		base_color = base_color.lightened(0.22)

	var normal_style: StyleBoxFlat = StyleBoxFlat.new()
	normal_style.bg_color = base_color
	normal_style.border_color = border_color
	normal_style.set_border_width_all(border_width)
	normal_style.set_corner_radius_all(10)

	var hover_style: StyleBoxFlat = normal_style.duplicate() as StyleBoxFlat
	hover_style.bg_color = base_color.lightened(0.18)

	var pressed_style: StyleBoxFlat = normal_style.duplicate() as StyleBoxFlat
	pressed_style.bg_color = base_color.darkened(0.18)

	add_theme_stylebox_override("normal", normal_style)
	add_theme_stylebox_override("hover", hover_style)
	add_theme_stylebox_override("pressed", pressed_style)
	add_theme_stylebox_override("focus", normal_style)
	add_theme_color_override("font_color", Color.WHITE)
	add_theme_color_override("font_hover_color", Color.WHITE)
	add_theme_color_override("font_pressed_color", Color.WHITE)
	add_theme_color_override("font_focus_color", Color.WHITE)

func _on_pressed() -> void:
	print("Region clicked: ", region_id, " / ", region_name)
	emit_signal("region_clicked", region_id)
