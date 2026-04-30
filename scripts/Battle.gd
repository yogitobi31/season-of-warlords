extends Node2D

# 10 vs 10 자동전투를 실행하는 최소 전투 컨트롤러

const UNITS_PER_TEAM := 10

var player_units: Array[Unit] = []
var enemy_units: Array[Unit] = []
var result_label: Label
var count_label: Label
var _battle_finished := false

func _ready() -> void:
	create_ui()
	spawn_teams()
	update_battle_ui()

func create_ui() -> void:
	result_label = Label.new()
	result_label.position = Vector2(20, 20)
	result_label.size = Vector2(1240, 48)
	result_label.text = GameState.get_battle_title()
	add_child(result_label)

	count_label = Label.new()
	count_label.position = Vector2(20, 68)
	count_label.size = Vector2(1240, 40)
	count_label.text = "병력 집계 중..."
	add_child(count_label)

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
	update_battle_ui()

	for unit in player_units:
		unit.tick_ai(delta, enemy_units)
	for unit in enemy_units:
		unit.tick_ai(delta, player_units)

	player_units = _filter_alive(player_units)
	enemy_units = _filter_alive(enemy_units)
	update_battle_ui()

	if player_units.is_empty() or enemy_units.is_empty():
		finish_battle(not player_units.is_empty())

func update_battle_ui() -> void:
	var player_count := player_units.size()
	var enemy_count := enemy_units.size()
	var player_name := GameState.get_faction_name(GameState.PLAYER_FACTION)
	var enemy_name := "적군"
	if GameState.defense_region_id != "":
		enemy_name = GameState.get_faction_name(GameState.get_region_owner(GameState.defense_region_id))
	count_label.text = "%s %d명 / %s %d명" % [player_name, player_count, enemy_name, enemy_count]

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
	result_label.text = GameState.last_battle_message
	count_label.text = "전투 종료 - 월드맵으로 복귀합니다."

	# 잠깐 결과를 보여준 뒤 월드맵으로 되돌아갑니다.
	await get_tree().create_timer(1.8).timeout
	get_tree().change_scene_to_file("res://scenes/WorldMap.tscn")
