extends Node2D

const BATTLE_SCENE_PATH := "res://scenes/Battle.tscn"

@onready var status_label: Label = $CanvasLayer/UIRoot/StatusLabel
@onready var message_label: Label = $CanvasLayer/UIRoot/MessageLabel
@onready var region_container: Control = $CanvasLayer/UIRoot/RegionContainer

var region_buttons: Dictionary = {}

func _ready() -> void:
	print("WorldMap ready - regions initialized")
	_prepare_map_data()
	_bind_region_buttons()
	_refresh_region_buttons()
	show_default_message()

func _prepare_map_data() -> void:
	if GameState.regions.is_empty():
		GameState.initialize_regions()
	for id in ["r1", "r2", "r3", "r4", "r5", "r6"]:
		if GameState.regions.has(id):
			GameState.regions[id]["name"] = _display_name(id)

func _bind_region_buttons() -> void:
	for child in region_container.get_children():
		if child is Button:
			var region_id := child.name
			region_buttons[region_id] = child
			(child as Button).pressed.connect(func() -> void:
				_on_region_clicked(region_id)
			)

func _display_name(region_id: String) -> String:
	match region_id:
		"r1": return "수도"
		"r2": return "북부성"
		"r3": return "동부평야"
		"r4": return "서부관문"
		"r5": return "남부항구"
		"r6": return "중앙산맥"
		_: return region_id

func _refresh_region_buttons() -> void:
	for region_id in region_buttons.keys():
		var button: Button = region_buttons[region_id]
		var owner := GameState.get_region_owner(region_id)
		button.modulate = GameState.FACTION_COLORS.get(owner, Color.DIM_GRAY)
		button.text = "%s\n소유: %s" % [_display_name(region_id), GameState.FACTION_NAMES.get(owner, "Neutral")]

func show_default_message() -> void:
	status_label.text = "선택 상태: 없음"
	if GameState.last_battle_result == "player_win":
		message_label.text = "직전 전투 결과: 승리. 공격할 지역을 고르세요."
	elif GameState.last_battle_result == "player_lose":
		message_label.text = "직전 전투 결과: 패배. 다시 공격할 지역을 고르세요."
	else:
		message_label.text = "내 지역을 먼저 선택하세요."

func _on_region_clicked(region_id: String) -> void:
	var owner := GameState.get_region_owner(region_id)

	if GameState.selected_region_id == "":
		if owner != GameState.PLAYER_FACTION:
			message_label.text = "먼저 아군 지역을 선택하세요"
			return
		GameState.selected_region_id = region_id
		status_label.text = "선택 상태: %s" % _display_name(region_id)
		message_label.text = "인접한 적 지역을 선택하세요."
		return

	if region_id == GameState.selected_region_id:
		GameState.clear_selection()
		show_default_message()
		return

	if not GameState.is_adjacent(GameState.selected_region_id, region_id):
		message_label.text = "인접 지역이 아닙니다"
		return

	if owner == GameState.PLAYER_FACTION:
		message_label.text = "아군 지역입니다. 적 지역을 선택하세요."
		return

	GameState.set_battle_context(GameState.selected_region_id, region_id)
	get_tree().change_scene_to_file(BATTLE_SCENE_PATH)
