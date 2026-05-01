extends Node2D

# 10 vs 10 자동전투를 실행하는 최소 전투 컨트롤러

const UNITS_PER_TEAM: int = 10

var player_units: Array[Unit] = []
var enemy_units: Array[Unit] = []
var result_label: Label
var count_label: Label
var companions_label: Label
var _battle_finished: bool = false

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
	var front_center_y: float = 360.0
	var deployed_companions: Array[String] = []
	var soldier_hp_bonus: float = GameState.get_soldier_hp_bonus()
	var soldier_attack_bonus: float = GameState.get_soldier_attack_bonus()
	var morale_bonus: float = GameState.get_army_morale_bonus()
	var companion_count: int = joined_companions.size()
	if companion_count > UNITS_PER_TEAM:
		companion_count = UNITS_PER_TEAM

	for i: int in range(UNITS_PER_TEAM):
		var p: Unit = Unit.new()
		p.team = Unit.TEAM_PLAYER
		if i < companion_count:
			var companion: Dictionary = joined_companions[i]
			p.is_companion = true
			p.unit_name = str(companion.get("name", "동료"))
			p.level = int(companion.get("level", 1))
			_apply_companion_stats(p, str(companion.get("id", "")), p.level)
			p.max_hp += soldier_hp_bonus * 0.35
			p.attack_power += soldier_attack_bonus * 0.35
			p.attack_power += morale_bonus
			deployed_companions.append(p.unit_name)
		else:
			p.max_hp += soldier_hp_bonus
			p.attack_power += soldier_attack_bonus + morale_bonus
		var lane: int = i % 5
		var row: int = i / 5
		var hero_offset: float = -12.0 if p.is_companion else 0.0
		p.global_position = Vector2(250 + row * 60 + hero_offset, front_center_y - 120.0 + float(lane) * 60.0)
		add_child(p)
		player_units.append(p)

		var e: Unit = Unit.new()
		e.team = Unit.TEAM_ENEMY
		var enemy_lane: int = i % 5
		var enemy_row: int = i / 5
		e.global_position = Vector2(1030 - enemy_row * 56, front_center_y - 125.0 + float(enemy_lane) * 58.0)
		add_child(e)
		enemy_units.append(e)

	if deployed_companions.is_empty():
		companions_label.text = "출전 동료: 없음"
	else:
		companions_label.text = "출전 동료: %s" % ", ".join(deployed_companions)

func _apply_companion_stats(unit: Unit, companion_id: String, level: int) -> void:
	var level_bonus: int = level - 1
	if level_bonus < 0:
		level_bonus = 0

	match companion_id:
		"leon":
			unit.max_hp += 40.0 + float(level_bonus) * 6.0
		"garon":
			unit.attack_power += 5.0 + float(level_bonus) * 1.2
		"elin":
			unit.move_speed += 40.0 + float(level_bonus) * 4.0
		"mira":
			unit.attack_range += 28.0 + float(level_bonus) * 2.5
		_:
			unit.max_hp += 20.0 + float(level_bonus) * 4.0

func _process(delta: float) -> void:
	if _battle_finished:
		return

	# 유효하지 않은 유닛 정리
	player_units = _filter_alive(player_units)
	enemy_units = _filter_alive(enemy_units)
	update_battle_ui()

	for unit: Unit in player_units:
		unit.tick_ai(delta, enemy_units)
	for unit: Unit in enemy_units:
		unit.tick_ai(delta, player_units)

	player_units = _filter_alive(player_units)
	enemy_units = _filter_alive(enemy_units)
	update_battle_ui()

	if player_units.is_empty() or enemy_units.is_empty():
		finish_battle(not player_units.is_empty())

func update_battle_ui() -> void:
	var player_count: int = player_units.size()
	var enemy_count: int = enemy_units.size()
	var player_name: String = GameState.get_faction_name(GameState.PLAYER_FACTION)
	var enemy_name: String = "적군"
	if GameState.defense_region_id != "":
		enemy_name = GameState.get_faction_name(GameState.get_region_owner(GameState.defense_region_id))
	count_label.text = "%s %d명 / %s %d명" % [player_name, player_count, enemy_name, enemy_count]

func _filter_alive(units: Array[Unit]) -> Array[Unit]:
	var result: Array[Unit] = []
	for u: Unit in units:
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
