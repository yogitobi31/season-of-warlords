extends Node2D

# 10 vs 10 자동전투를 실행하는 최소 전투 컨트롤러

const UNITS_PER_TEAM := 10

var player_units: Array[Unit] = []
var enemy_units: Array[Unit] = []
var result_label: Label
var _battle_finished := false

func _ready() -> void:
	create_ui()
	spawn_teams()

func create_ui() -> void:
	result_label = Label.new()
	result_label.position = Vector2(20, 20)
	result_label.size = Vector2(1240, 80)
	result_label.text = "전투 시작! 자동으로 진행됩니다."
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
	_battle_finished = true
	GameState.apply_battle_result(player_won)
	if player_won:
		result_label.text = "승리! 점령 후 월드맵으로 복귀합니다."
	else:
		result_label.text = "패배... 월드맵으로 복귀합니다."

	# 잠깐 결과를 보여준 뒤 월드맵으로 되돌아갑니다.
	await get_tree().create_timer(1.2).timeout
	get_tree().change_scene_to_file("res://scenes/WorldMap.tscn")
