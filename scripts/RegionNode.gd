extends Area2D
class_name RegionNode

signal region_clicked(region_id: String)

@export var region_id: String = ""
@export var region_name: String = ""
@export var owner_faction: int = 0
@export var adjacent_regions: Array = []

var _shape_node: ColorRect
var _name_label: Label

func _ready() -> void:
	input_pickable = true
	# 단순 사각형으로 지역을 표현합니다.
	_shape_node = ColorRect.new()
	_shape_node.size = Vector2(120, 64)
	_shape_node.position = Vector2(-60, -32)
	_shape_node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_shape_node)

	_name_label = Label.new()
	_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_name_label.size = Vector2(120, 64)
	_name_label.position = Vector2(-60, -32)
	_name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_name_label)

	# 클릭 판정 영역을 설정합니다.
	var collision := CollisionShape2D.new()
	var rect_shape := RectangleShape2D.new()
	rect_shape.size = Vector2(120, 64)
	collision.shape = rect_shape
	add_child(collision)

	update_visual()

func setup(id: String, display_name: String, faction_id: int, neighbors: Array) -> void:
	region_id = id
	region_name = display_name
	owner_faction = faction_id

	adjacent_regions.clear()
	for neighbor in neighbors:
		adjacent_regions.append(str(neighbor))

	if is_inside_tree():
		update_visual()

func update_owner(faction_id: int) -> void:
	owner_faction = faction_id
	update_visual()

func update_visual() -> void:
	if _shape_node == null or _name_label == null:
		return
	_shape_node.color = GameState.FACTION_COLORS.get(owner_faction, Color.DIM_GRAY)
	_name_label.text = "%s\n(%s)" % [region_name, GameState.FACTION_NAMES.get(owner_faction, "Unknown")]

func _input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("Region clicked: ", region_id)
		emit_signal("region_clicked", region_id)
