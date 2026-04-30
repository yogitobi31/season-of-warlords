extends Node2D

# 월드맵 MVP 흐름:
# 1) 플레이어 소유 지역 선택
# 2) 인접한 적 지역 선택
# 3) 전투 씬으로 전환

var region_nodes: Dictionary = {}
var info_label: Label

func _ready() -> void:
	print("WorldMap ready")
	create_ui()
	spawn_regions()
	refresh_regions()
	show_default_message()

func create_ui() -> void:
	info_label = Label.new()
	info_label.position = Vector2(20, 20)
	info_label.size = Vector2(1200, 96)
	info_label.text = "월드맵 준비 중..."
	add_child(info_label)

func spawn_regions() -> void:
	print("Spawning regions")
	for region_id in GameState.regions.keys():
		var data: Dictionary = GameState.regions[region_id]
		var node := RegionNode.new()
		node.position = data["pos"]
		node.setup(region_id, data["name"], GameState.get_region_owner(region_id), data["adjacent"])
		node.region_clicked.connect(_on_region_clicked)
		add_child(node)
		region_nodes[region_id] = node
		print("Region created: ", data["name"])

func refresh_regions() -> void:
	for region_id in region_nodes.keys():
		var node: RegionNode = region_nodes[region_id]
		node.update_owner(GameState.get_region_owner(region_id))
		node.set_selected(region_id == GameState.selected_region_id)
		node.set_attackable(_is_attackable_from_selection(region_id))

func show_default_message() -> void:
	var result_text := ""
	if GameState.last_battle_result == "player_win":
		result_text = "직전 전투 결과: 승리! 지역을 점령했습니다.\n"
	elif GameState.last_battle_result == "player_lose":
		result_text = "직전 전투 결과: 패배...\n"
	info_label.text = result_text + "청람 왕국 지역을 먼저 클릭한 뒤, 인접한 적 지역을 클릭하세요."

func _on_region_clicked(region_id: String) -> void:
	print("WorldMap received region click: ", region_id)
	var region_owner := GameState.get_region_owner(region_id)

	if GameState.selected_region_id == "":
		# 1단계: 플레이어 소유 지역만 시작점으로 선택 가능
		if region_owner != GameState.PLAYER_FACTION:
			info_label.text = "먼저 청람 왕국 소유 지역을 선택하세요."
			refresh_regions()
			return
		GameState.selected_region_id = region_id
		info_label.text = "선택된 지역: %s\n인접한 적 지역을 선택하세요." % GameState.regions[region_id]["name"]
		refresh_regions()
		return

	# 이미 시작 지역을 선택한 경우: 같은 지역을 다시 누르면 선택 해제
	if region_id == GameState.selected_region_id:
		GameState.clear_selection()
		show_default_message()
		refresh_regions()
		return

	# 2단계: 인접 체크
	if not GameState.is_adjacent(GameState.selected_region_id, region_id):
		info_label.text = "인접하지 않은 지역입니다. 다른 지역을 선택하세요."
		refresh_regions()
		return

	# 3단계: 적 지역 체크
	if region_owner == GameState.PLAYER_FACTION:
		info_label.text = "아군 지역입니다. 인접한 적 지역을 선택하세요."
		refresh_regions()
		return

	# 전투 진입 정보 설정 후 전투 씬 전환
	print("Starting battle from ", GameState.selected_region_id, " to ", region_id)
	GameState.set_battle_context(GameState.selected_region_id, region_id)
	get_tree().change_scene_to_file("res://scenes/Battle.tscn")

func _is_attackable_from_selection(region_id: String) -> bool:
	if GameState.selected_region_id == "":
		return false
	if region_id == GameState.selected_region_id:
		return false
	if not GameState.is_adjacent(GameState.selected_region_id, region_id):
		return false
	return GameState.get_region_owner(region_id) != GameState.PLAYER_FACTION
