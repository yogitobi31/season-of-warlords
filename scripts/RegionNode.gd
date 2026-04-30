extends Button
class_name RegionNode

signal region_clicked(region_id: String)

@export var region_id: String = ""
@export var region_name: String = ""
@export var owner_faction: int = 0
@export var adjacent_regions: Array = []

var _base_style: StyleBoxFlat

func _ready() -> void:
	custom_minimum_size = Vector2(140, 60)
	size = Vector2(140, 60)
	focus_mode = Control.FOCUS_NONE
	autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	pressed.connect(_on_pressed)
	_build_base_style()
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
	if _base_style == null:
		_build_base_style()
	_base_style.bg_color = GameState.FACTION_COLORS.get(owner_faction, Color.DIM_GRAY)
	text = "%s\n(%s)" % [region_name, GameState.FACTION_NAMES.get(owner_faction, "Unknown")]
	add_theme_stylebox_override("normal", _base_style)
	add_theme_stylebox_override("hover", _base_style)
	add_theme_stylebox_override("pressed", _base_style)

func set_selected(selected: bool) -> void:
	if selected:
		var selected_style := _base_style.duplicate() as StyleBoxFlat
		selected_style.border_width_left = 4
		selected_style.border_width_top = 4
		selected_style.border_width_right = 4
		selected_style.border_width_bottom = 4
		selected_style.border_color = Color.YELLOW
		add_theme_stylebox_override("normal", selected_style)
		add_theme_stylebox_override("hover", selected_style)
		add_theme_stylebox_override("pressed", selected_style)
	else:
		update_visual()

func set_attackable(attackable: bool) -> void:
	if attackable:
		var attack_style := _base_style.duplicate() as StyleBoxFlat
		attack_style.border_width_left = 3
		attack_style.border_width_top = 3
		attack_style.border_width_right = 3
		attack_style.border_width_bottom = 3
		attack_style.border_color = Color(1.0, 0.85, 0.2)
		add_theme_stylebox_override("normal", attack_style)
		add_theme_stylebox_override("hover", attack_style)
		add_theme_stylebox_override("pressed", attack_style)
	else:
		update_visual()

func _build_base_style() -> void:
	_base_style = StyleBoxFlat.new()
	_base_style.bg_color = Color.DIM_GRAY
	_base_style.corner_radius_top_left = 8
	_base_style.corner_radius_top_right = 8
	_base_style.corner_radius_bottom_right = 8
	_base_style.corner_radius_bottom_left = 8

func _on_pressed() -> void:
	print("Region clicked: ", region_id)
	emit_signal("region_clicked", region_id)
