extends Node2D

var region_nodes: Dictionary = {}
var info_label: Label
var companions_label: Label
var fortress_button: Button
var fortress_panel: Panel
var fortress_label: Label
var return_button: Button
var event_panel: Panel
var event_title_label: Label
var event_speaker_label: Label
var event_dialogue_label: Label
var event_choices_container: VBoxContainer

func _ready() -> void:
	create_ui()
	spawn_regions()
	refresh_regions()
	show_default_message()
	refresh_companions_panel()
	refresh_fortress_panel()
	refresh_story_event_panel()

func create_ui() -> void:
	info_label = Label.new()
	info_label.position = Vector2(20, 20)
	info_label.size = Vector2(860, 120)
	info_label.text = "출정 지도 준비 중..."
	add_child(info_label)

	companions_label = Label.new()
	companions_label.position = Vector2(910, 20)
	companions_label.size = Vector2(360, 280)
	companions_label.text = "동료 정보를 불러오는 중..."
	add_child(companions_label)

	fortress_button = Button.new()
	fortress_button.text = "성채 보기"
	fortress_button.position = Vector2(910, 310)
	fortress_button.size = Vector2(180, 40)
	fortress_button.pressed.connect(_on_fortress_button_pressed)
	add_child(fortress_button)

	return_button = Button.new()
	return_button.text = "성채로 돌아가기"
	return_button.position = Vector2(1110, 310)
	return_button.size = Vector2(160, 40)
	return_button.pressed.connect(_on_return_button_pressed)
	add_child(return_button)

	fortress_panel = Panel.new()
	fortress_panel.position = Vector2(910, 360)
	fortress_panel.size = Vector2(360, 300)
	fortress_panel.visible = false
	add_child(fortress_panel)

	fortress_label = Label.new()
	fortress_label.position = Vector2(12, 12)
	fortress_label.size = Vector2(336, 276)
	fortress_panel.add_child(fortress_label)

	event_panel = Panel.new()
	event_panel.position = Vector2(350, 180)
	event_panel.size = Vector2(620, 320)
	event_panel.visible = false
	add_child(event_panel)

	event_title_label = Label.new()
	event_title_label.position = Vector2(16, 12)
	event_title_label.size = Vector2(588, 30)
	event_panel.add_child(event_title_label)

	event_speaker_label = Label.new()
	event_speaker_label.position = Vector2(16, 46)
	event_speaker_label.size = Vector2(588, 24)
	event_panel.add_child(event_speaker_label)

	event_dialogue_label = Label.new()
	event_dialogue_label.position = Vector2(16, 74)
	event_dialogue_label.size = Vector2(588, 130)
	event_panel.add_child(event_dialogue_label)

	event_choices_container = VBoxContainer.new()
	event_choices_container.position = Vector2(16, 216)
	event_choices_container.size = Vector2(588, 90)
	event_panel.add_child(event_choices_container)

func spawn_regions() -> void:
	for region_id in GameState.regions.keys():
		var data: Dictionary = GameState.regions[region_id]
		var node: RegionNode = RegionNode.new()
		node.position = data["pos"]
		node.setup(region_id, data["name"], GameState.get_region_owner(region_id), data["adjacent"])
		node.region_clicked.connect(_on_region_clicked)
		add_child(node)
		region_nodes[region_id] = node

func refresh_regions() -> void:
	for region_id in region_nodes.keys():
		var node: RegionNode = region_nodes[region_id]
		node.update_owner(GameState.get_region_owner(region_id))
		node.set_selected(region_id == GameState.selected_region_id)
		node.set_attackable(_is_attackable_from_selection(region_id))

func refresh_companions_panel() -> void:
	var lines: Array[String] = ["동료"]
	for companion in GameState.get_companions_list():
		if companion.get("joined", false):
			lines.append("%s Lv.%d EXP %d/100" % [
				companion.get("name", "?"),
				int(companion.get("level", 1)),
				int(companion.get("exp", 0))
			])
		else:
			lines.append("%s 미합류" % companion.get("name", "?"))
	companions_label.text = "\n".join(lines)

func refresh_fortress_panel() -> void:
	var lines: Array[String] = []
	lines.append("%s Lv.%d" % [GameState.fortress_data["name"], GameState.fortress_data["level"]])
	lines.append("")
	lines.append("시설")
	for facility in GameState.fortress_data["facilities"]:
		lines.append("- %s Lv.%d" % [facility["name"], facility["level"]])
	lines.append("")
	lines.append("보유 동료")
	for companion in GameState.get_joined_companions():
		lines.append("- %s Lv.%d" % [companion["name"], companion["level"]])
	fortress_label.text = "\n".join(lines)

func show_default_message() -> void:
	var result_text: String = ""
	if GameState.last_battle_message != "":
		result_text = "직전 전투 결과:\n%s\n\n" % GameState.last_battle_message
	info_label.text = result_text + "출정 지도: 청람 왕국의 세력을 확장할 지역을 선택하세요.\n청람 왕국 지역을 먼저 클릭한 뒤, 인접한 적 지역을 클릭하세요."

func refresh_story_event_panel() -> void:
	for child in event_choices_container.get_children():
		child.queue_free()

	if not GameState.has_pending_story_event():
		event_panel.visible = false
		return

	var event_data: Dictionary = GameState.get_pending_story_event()
	event_title_label.text = "[%s]" % str(event_data.get("title", "이벤트"))
	var speaker_name: String = str(event_data.get("speaker_name", "???"))
	event_speaker_label.text = "화자: %s" % speaker_name
	var dialogue_lines: Array[String] = []
	for line_variant: Variant in event_data.get("dialogue_lines", []):
		dialogue_lines.append(str(line_variant))
	var dialogue_text: String = ""
	for line: String in dialogue_lines:
		dialogue_text += "\"%s\"\n" % line
	event_dialogue_label.text = dialogue_text.strip_edges()

	var choices: Array = event_data.get("choices", [])
	for i: int in range(choices.size()):
		var choice_button: Button = Button.new()
		choice_button.text = "[%s]" % str(choices[i])
		choice_button.pressed.connect(_on_story_choice_selected.bind(i))
		event_choices_container.add_child(choice_button)
	event_panel.visible = true

func _on_story_choice_selected(choice_index: int) -> void:
	var recruit_message: String = GameState.resolve_pending_story_event(choice_index)
	if recruit_message != "":
		GameState.last_battle_message = recruit_message
		info_label.text = recruit_message
	refresh_companions_panel()
	refresh_fortress_panel()
	refresh_story_event_panel()

func _on_region_clicked(region_id: String) -> void:
	if GameState.has_pending_story_event():
		info_label.text = "진행 중인 동료 이벤트를 먼저 선택하세요."
		return

	var region_owner: int = GameState.get_region_owner(region_id)

	if GameState.selected_region_id == "":
		if region_owner != GameState.PLAYER_FACTION:
			info_label.text = "먼저 청람 왕국 소유 지역을 선택하세요."
			refresh_regions()
			return
		GameState.selected_region_id = region_id
		info_label.text = "선택된 지역: %s\n인접한 적 지역을 선택하세요." % GameState.regions[region_id]["name"]
		refresh_regions()
		return

	if region_id == GameState.selected_region_id:
		GameState.clear_selection()
		show_default_message()
		refresh_regions()
		return

	if not GameState.is_adjacent(GameState.selected_region_id, region_id):
		info_label.text = "인접하지 않은 지역입니다. 다른 지역을 선택하세요."
		refresh_regions()
		return

	if region_owner == GameState.PLAYER_FACTION:
		info_label.text = "아군 지역입니다. 인접한 적 지역을 선택하세요."
		refresh_regions()
		return

	GameState.set_battle_context(GameState.selected_region_id, region_id)
	get_tree().change_scene_to_file("res://scenes/Battle.tscn")

func _on_fortress_button_pressed() -> void:
	fortress_panel.visible = not fortress_panel.visible
	refresh_fortress_panel()

func _is_attackable_from_selection(region_id: String) -> bool:
	if GameState.selected_region_id == "":
		return false
	if region_id == GameState.selected_region_id:
		return false
	if not GameState.is_adjacent(GameState.selected_region_id, region_id):
		return false
	return GameState.get_region_owner(region_id) != GameState.PLAYER_FACTION


func _on_return_button_pressed() -> void:
	GameState.clear_selection()
	get_tree().change_scene_to_file("res://scenes/CastleHub.tscn")
