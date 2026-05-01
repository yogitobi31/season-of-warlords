extends Node2D

# 10 vs 10 자동전투를 실행하는 최소 전투 컨트롤러

const UNITS_PER_TEAM := 10

var player_units: Array[Unit] = []
var enemy_units: Array[Unit] = []
var result_label: Label
var count_label: Label
var companions_label: Label
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

	companions_label = Label.new()
	companions_label.position = Vector2(20, 108)
	companions_label.size = Vector2(1240, 36)
	companions_label.text = "출전 동료: 없음"
	add_child(companions_label)

func spawn_teams() -> void:
	var joined_companions: Array = GameState.get_joined_companions()
	var deployed_companions: Array[String] = []
	var companion_count := min(joined_companions.size(), UNITS_PER_TEAM)

	for i in UNITS_PER_TEAM:
		var p := Unit.new()
		p.team = Unit.TEAM_PLAYER
		if i < companion_count:
			var companion: Dictionary = joined_companions[i]
			p.is_companion = true
			p.unit_name = str(companion.get("name", "동료"))
			p.level = int(companion.get("level", 1))
			_apply_companion_stats(p, str(companion.get("id", "")), p.level)
			deployed_companions.append(p.unit_name)
		p.global_position = Vector2(180 + i * 22, 170 + (i % 5) * 70)
		add_child(p)
		player_units.append(p)

		var e := Unit.new()
		e.team = Unit.TEAM_ENEMY
		e.global_position = Vector2(1100 - i * 22, 170 + (i % 5) * 70)
		add_child(e)
		enemy_units.append(e)

	if deployed_companions.is_empty():
		companions_label.text = "출전 동료: 없음"
	else:
		companions_label.text = "출전 동료: %s" % ", ".join(deployed_companions)

func _apply_companion_stats(unit: Unit, companion_id: String, level: int) -> void:
	var level_bonus := max(level - 1, 0)
	match companion_id:
		"leon":
			unit.max_hp += 40.0 + level_bonus * 6.0
		"garon":
			unit.attack_power += 5.0 + level_bonus * 1.2
		"elin":
			unit.move_speed += 40.0 + level_bonus * 4.0
		"mira":
			unit.attack_range += 28.0 + level_bonus * 2.5
		_:
			unit.max_hp += 20.0 + level_bonus * 4.0

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
