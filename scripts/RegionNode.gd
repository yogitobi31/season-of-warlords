extends Button
class_name RegionNode

signal region_clicked(region_id: String)
signal region_hovered(region_id: String, active: bool)

@export var region_id: String = ""
@export var region_name: String = ""
@export var owner_faction: int = 0
@export var adjacent_regions: Array = []

const CLICK_SIZE: Vector2 = Vector2(48, 48)
const MARKER_SIZE: Vector2 = Vector2(22, 22)
const LABEL_OFFSET_Y: float = -38.0

var is_selected: bool = false
var is_attackable: bool = false
var is_rumor_target: bool = false
var danger_text: String = ""
var is_hovered: bool = false

var marker_panel: Panel
var name_label: Label
var rumor_label: Label

func _ready() -> void:
	custom_minimum_size = CLICK_SIZE
	size = CLICK_SIZE
	focus_mode = Control.FOCUS_NONE
	mouse_filter = Control.MOUSE_FILTER_STOP
	flat = true
	text = ""
	clip_text = false
	if not pressed.is_connected(_on_pressed):
		pressed.connect(_on_pressed)
	if not mouse_entered.is_connected(_on_mouse_entered):
		mouse_entered.connect(_on_mouse_entered)
	if not mouse_exited.is_connected(_on_mouse_exited):
		mouse_exited.connect(_on_mouse_exited)
	_setup_children()
	update_visual()

func _setup_children() -> void:
	if marker_panel == null:
		marker_panel = Panel.new()
		marker_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
		marker_panel.position = (CLICK_SIZE - MARKER_SIZE) * 0.5
		marker_panel.size = MARKER_SIZE
		add_child(marker_panel)

	if rumor_label == null:
		rumor_label = Label.new()
		rumor_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		rumor_label.text = "★"
		rumor_label.add_theme_color_override("font_color", Color(1.0, 0.92, 0.25))
		rumor_label.add_theme_font_size_override("font_size", 14)
		rumor_label.position = Vector2(CLICK_SIZE.x - 14.0, 1.0)
		rumor_label.visible = false
		add_child(rumor_label)

	if name_label == null:
		name_label = Label.new()
		name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_label.autowrap_mode = TextServer.AUTOWRAP_OFF
		name_label.size = Vector2(170, 34)
		name_label.position = Vector2((CLICK_SIZE.x - name_label.size.x) * 0.5, LABEL_OFFSET_Y)
		name_label.visible = false
		name_label.add_theme_font_size_override("font_size", 12)
		name_label.add_theme_color_override("font_color", Color(0.95, 0.97, 1.0))
		name_label.add_theme_constant_override("line_spacing", 1)
		add_child(name_label)

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
	custom_minimum_size = CLICK_SIZE
	size = CLICK_SIZE
	text = ""

	if marker_panel == null or name_label == null or rumor_label == null:
		return

	var base_color: Color = Color.DIM_GRAY
	if owner_faction == GameState.PLAYER_FACTION:
		base_color = Color(0.18, 0.35, 0.76)
	elif owner_faction == GameState.CRIMSON_DUCHY_FACTION:
		base_color = Color(0.7, 0.2, 0.2)
	elif owner_faction == GameState.GREEN_MARQUIS_FACTION:
		base_color = Color(0.24, 0.5, 0.24)

	if danger_text == "이벤트":
		base_color = base_color.lightened(0.22)

	var border_color: Color = Color(0.08, 0.08, 0.08)
	var border_width: int = 1
	if is_attackable:
		border_color = Color(1.0, 0.65, 0.0)
		border_width = 2
	if is_selected:
		border_color = Color(1.0, 0.95, 0.1)
		border_width = 3
	if is_rumor_target:
		border_color = Color(1.0, 0.9, 0.2)
		if border_width < 3:
			border_width = 3

	var marker_style: StyleBoxFlat = StyleBoxFlat.new()
	marker_style.bg_color = base_color
	marker_style.border_color = border_color
	marker_style.set_border_width_all(border_width)
	marker_style.set_corner_radius_all(11)
	marker_panel.add_theme_stylebox_override("panel", marker_style)

	var hover_style: StyleBoxFlat = StyleBoxFlat.new()
	hover_style.bg_color = Color(0, 0, 0, 0)
	hover_style.border_color = Color(1.0, 1.0, 1.0, 0.32)
	hover_style.set_border_width_all(1)
	hover_style.set_corner_radius_all(8)
	add_theme_stylebox_override("hover", hover_style)
	add_theme_stylebox_override("normal", StyleBoxEmpty.new())
	add_theme_stylebox_override("pressed", StyleBoxEmpty.new())
	add_theme_stylebox_override("focus", StyleBoxEmpty.new())

	rumor_label.visible = is_rumor_target
	name_label.visible = is_hovered or is_selected or is_rumor_target
	if name_label.visible:
		var label_text: String = region_name
		if danger_text != "":
			label_text += "\n위험: %s" % danger_text
		name_label.text = label_text

	# 향후 줌 단계가 추가되면 여기에서 라벨 표시 조건을 확대/축소 비율 기반으로 분기합니다.

func _on_pressed() -> void:
	emit_signal("region_clicked", region_id)

func _on_mouse_entered() -> void:
	is_hovered = true
	update_visual()
	emit_signal("region_hovered", region_id, true)

func _on_mouse_exited() -> void:
	is_hovered = false
	update_visual()
	emit_signal("region_hovered", region_id, false)
