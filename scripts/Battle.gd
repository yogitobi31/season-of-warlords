extends Node2D

# 10 vs 10 자동전투를 실행하는 최소 전투 컨트롤러

const UNITS_PER_TEAM := 10

var player_units: Array[Unit] = []
var enemy_units: Array[Unit] = []
var battle_info_label: Label
var unit_count_label: Label
var result_label: Label
var _battle_finished := false

func _ready() -> void:
	create_ui()
	spawn_teams()
	_update_unit_count_label()

func create_ui() -> void:
	battle_info_label = Label.new()
	battle_info_label.position = Vector2(20, 16)
	battle_info_label.size = Vector2(1240, 36)
	battle_info_label.text = _make_battle_info_text()
	add_child(battle_info_label)

	unit_count_label = Label.new()
	unit_count_label.position = Vector2(20, 52)
	unit_count_label.size = Vector2(1240, 36)
	unit_count_label.text = ""
	add_child(unit_count_label)

	result_label = Label.new()
	result_label.position = Vector2(140, 250)
	result_label.size = Vector2(1000, 200)
	result_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	result_label.add_theme_font_size_override("font_size", 42)
	result_label.visible = false
	add_child(result_label)

func spawn_teams() -> void:
	for i in UNITS_PER_TEAM:
		var p := Unit.new()
		p.team = Unit.TEAM_PLAYER
		p.global_position = Vector2(180 + i * 22, 170 + (i % 5) * 70)
		add_child(p)
		player_units.append(p)

		var e := Unit.new()
		e.team = Unit.TEAM_ENEMY
		e.global_position = Vector2(1100 - i * 22, 170 + (i % 5) * 70)
		add_child(e)
		enemy_units.append(e)

func _process(delta: float) -> void:
	if _battle_finished:
		return

	# 유효하지 않은 유닛 정리
	player_units = _filter_alive(player_units)
	enemy_units = _filter_alive(enemy_units)
	_update_unit_count_label()

	for unit in player_units:
		unit.tick_ai(delta, enemy_units)
	for unit in enemy_units:
		unit.tick_ai(delta, player_units)

	if player_units.is_empty() or enemy_units.is_empty():
		finish_battle(not player_units.is_empty())

func _filter_alive(units: Array[Unit]) -> Array[Unit]:
	var result: Array[Unit] = []
	for u in units:
		if u != null and is_instance_valid(u) and u.is_alive():
			result.append(u)
	return result

func finish_battle(player_won: bool) -> void:
	if _battle_finished:
		return
	_battle_finished = true
	GameState.apply_battle_result(player_won)
	_update_unit_count_label()
	result_label.visible = true
	result_label.text = GameState.last_battle_message

	# 최소 1.5초 이상 결과를 보여준 뒤 월드맵으로 되돌아갑니다.
	await get_tree().create_timer(1.5).timeout
	get_tree().change_scene_to_file("res://scenes/WorldMap.tscn")

func _make_battle_info_text() -> String:
	var from_name := _region_name(GameState.attack_region_id)
	var to_name := _region_name(GameState.defense_region_id)
	return "전투: %s → %s" % [from_name, to_name]

func _region_name(region_id: String) -> String:
	if region_id != "" and GameState.regions.has(region_id):
		return str(GameState.regions[region_id].get("name", region_id))
	return "미지의 지역"

func _update_unit_count_label() -> void:
	unit_count_label.text = "%s %d명 / %s %d명" % [
		GameState.FACTION_NAMES.get(GameState.PLAYER_FACTION, "아군"),
		player_units.size(),
		GameState.FACTION_NAMES.get(1, "적군"),
		enemy_units.size()
	]
