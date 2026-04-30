extends Node2D

var region_nodes: Dictionary = {}
var info_label: Label

func _ready() -> void:
	create_ui()
	spawn_regions()
	refresh_regions()
	update_status("인접한 적 지역을 선택하세요")

func create_ui() -> void:
	info_label = Label.new()
	info_label.position = Vector2(20, 20)
	info_label.size = Vector2(1240, 96)
	add_child(info_label)

func spawn_regions() -> void:
	for region_id in GameState.regions.keys():
		var data: Dictionary = GameState.regions[region_id]
		var node := RegionNode.new()
		node.position = data["position"]
		node.setup(data["id"], data["name"], GameState.get_region_owner(region_id), data["neighbors"])
		node.region_clicked.connect(_on_region_clicked)
		add_child(node)
		region_nodes[region_id] = node

func refresh_regions() -> void:
	for region_id in region_nodes.keys():
		var node: RegionNode = region_nodes[region_id]
		node.update_owner(GameState.get_region_owner(region_id))

func update_status(message: String) -> void:
	var selected_name := "없음"
	var target_name := "없음"
	if GameState.selected_region_id != "" and GameState.regions.has(GameState.selected_region_id):
		selected_name = GameState.regions[GameState.selected_region_id]["name"]
	if GameState.defense_region_id != "" and GameState.regions.has(GameState.defense_region_id):
		target_name = GameState.regions[GameState.defense_region_id]["name"]

	var result_text := ""
	if GameState.last_battle_result == "player_win":
		result_text = "직전 전투: 승리\n"
	elif GameState.last_battle_result == "player_lose":
		result_text = "직전 전투: 패배\n"

	info_label.text = "%s선택된 지역: %s | 대상 지역: %s\n메시지: %s" % [result_text, selected_name, target_name, message]

func _on_region_clicked(region_id: String) -> void:
	var owner := GameState.get_region_owner(region_id)

	if GameState.selected_region_id == "":
		if owner != GameState.PLAYER_FACTION:
			update_status("먼저 아군 지역을 선택하세요")
			return
		GameState.selected_region_id = region_id
		GameState.defense_region_id = ""
		update_status("출발 지역 선택 완료. 인접한 적 지역을 선택하세요")
		return

	if region_id == GameState.selected_region_id:
		GameState.clear_selection()
		update_status("선택이 해제되었습니다. 아군 지역을 다시 선택하세요")
		return

	if not GameState.is_adjacent(GameState.selected_region_id, region_id):
		update_status("인접 지역이 아닙니다")
		return

	if owner == GameState.PLAYER_FACTION:
		update_status("아군 지역입니다. 인접한 적 지역을 선택하세요")
		return

	GameState.set_battle_context(GameState.selected_region_id, region_id)
	update_status("전투 씬으로 이동합니다")
	get_tree().change_scene_to_file("res://scenes/Battle.tscn")
