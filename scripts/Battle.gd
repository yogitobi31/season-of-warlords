extends Node2D

const UNITS_PER_TEAM: int = 10
const BASE_ENEMY_COUNT: int = 3
const ENEMY_SCALE_PER_COMPANION: int = 1

var player_units: Array[Unit] = []
var enemy_units: Array[Unit] = []
var result_label: Label
var count_label: Label
var companions_label: Label
var class_info_label: Label
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

	class_info_label = Label.new()
	class_info_label.position = Vector2(20, 146)
	class_info_label.size = Vector2(1240, 60)
	class_info_label.text = "상성: 창병은 기병에게 강하고, 기병은 궁수와 소서러에게 강합니다."
	add_child(class_info_label)

func spawn_teams() -> void:
	var joined_companions: Array = GameState.get_joined_companions()
	var front_center_y: float = 360.0
	var deployed_companions: Array[String] = []
	var soldier_hp_bonus: float = GameState.get_soldier_hp_bonus()
	var soldier_attack_bonus: float = GameState.get_soldier_attack_bonus()
	var morale_bonus: float = GameState.get_army_morale_bonus()
	var player_composition: Array[String] = GameState.get_player_composition()
	var enemy_base_classes: Array[String] = GameState.get_region_enemy_classes(GameState.defense_region_id)
	var companion_count: int = GameState.get_companion_count()
	if companion_count > UNITS_PER_TEAM:
		companion_count = UNITS_PER_TEAM

	for i: int in range(UNITS_PER_TEAM):
		var p: Unit = Unit.new()
		p.team = Unit.TEAM_PLAYER
		var class_id: String = player_composition[i] if i < player_composition.size() else "infantry"
		p.apply_class_stats(class_id)
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
		p.hp = p.max_hp
		var lane: int = i % 5
		var row: int = i / 5
		var hero_offset: float = -12.0 if p.is_companion else 0.0
		p.global_position = Vector2(250 + row * 60 + hero_offset, front_center_y - 120.0 + float(lane) * 60.0)
		add_child(p)
		player_units.append(p)

	var enemy_count: int = BASE_ENEMY_COUNT + (companion_count * ENEMY_SCALE_PER_COMPANION)
	print("[Battle] companion_count=%d enemy_count=%d" % [companion_count, enemy_count])
	for i: int in range(enemy_count):
		var e: Unit = Unit.new()
		e.team = Unit.TEAM_ENEMY
		var enemy_class_id: String = enemy_base_classes[i % enemy_base_classes.size()]
		e.apply_class_stats(enemy_class_id)
		e.hp = e.max_hp
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
	var player_name: String = GameState.get_faction_name(GameState.PLAYER_FACTION)
	var enemy_name: String = "적군"
	if GameState.defense_region_id != "":
		enemy_name = GameState.get_faction_name(GameState.get_region_owner(GameState.defense_region_id))
	count_label.text = "%s %d명 / %s %d명" % [player_name, player_units.size(), enemy_name, enemy_units.size()]
	class_info_label.text = "아군 병종: %s\n적군 병종: %s\n상성: 창병은 기병에게 강하고, 기병은 궁수와 소서러에게 강합니다." % [_format_class_counts(player_units), _format_class_counts(enemy_units)]

func _format_class_counts(units: Array[Unit]) -> String:
	var class_counts: Dictionary = {}
	for unit in units:
		var class_id: String = unit.unit_class
		if not class_counts.has(class_id):
			class_counts[class_id] = 0
		class_counts[class_id] = int(class_counts[class_id]) + 1
	var parts: Array[String] = []
	for class_id in class_counts.keys():
		var class_data: Dictionary = GameState.UNIT_CLASSES.get(class_id, {})
		parts.append("%s %d" % [str(class_data.get("display_name", class_id)), int(class_counts[class_id])])
	return ", ".join(parts)

func _filter_alive(units: Array[Unit]) -> Array[Unit]:
	var result: Array[Unit] = []
	for unit in units:
		if unit != null and is_instance_valid(unit) and unit.is_alive():
			result.append(unit)
	return result

func finish_battle(player_won: bool) -> void:
	if _battle_finished:
		return
	_battle_finished = true
	GameState.apply_battle_result(player_won)
	result_label.text = GameState.last_battle_message
	count_label.text = "전투 종료 - 월드맵으로 복귀합니다."
	await get_tree().create_timer(1.8).timeout
	get_tree().change_scene_to_file("res://scenes/WorldMap.tscn")
