extends Node2D

var region_nodes: Dictionary = {}
var info_label: Label
var region_detail_label: Label
var companions_label: Label
var fortress_button: Button
var fortress_panel: Panel
var fortress_label: Label
var return_button: Button
var event_overlay: ColorRect
var event_panel: Panel
var event_title_label: Label
var event_speaker_label: Label
var event_dialogue_label: Label
var event_choices_container: VBoxContainer
var story_event_result_active: bool = false
var story_event_result_speaker: String = ""
var story_event_result_text: String = ""
var story_event_join_message: String = ""
var story_event_result_battle_message: String = ""

func _ready() -> void:
	create_ui()
	create_route_lines()
	spawn_regions()
	refresh_regions()
	show_default_message()
	refresh_companions_panel()
	refresh_fortress_panel()
	refresh_story_event_panel()

func create_ui() -> void:
	var objective_panel: Panel = Panel.new()
	objective_panel.position = Vector2(20, 20)
	objective_panel.size = Vector2(520, 180)
	add_child(objective_panel)

	info_label = Label.new()
	info_label.position = Vector2(14, 12)
	info_label.size = Vector2(492, 156)
	info_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info_label.text = "출정 지도 준비 중..."
	objective_panel.add_child(info_label)

	var region_panel: Panel = Panel.new()
	region_panel.position = Vector2(900, 20)
	region_panel.size = Vector2(360, 350)
	add_child(region_panel)

	region_detail_label = Label.new()
	region_detail_label.position = Vector2(12, 10)
	region_detail_label.size = Vector2(336, 328)
	region_detail_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	region_detail_label.text = "지역을 선택하면 상세 정보가 표시됩니다."
	region_panel.add_child(region_detail_label)

	var status_panel: Panel = Panel.new()
	status_panel.position = Vector2(900, 380)
	status_panel.size = Vector2(360, 220)
	add_child(status_panel)

	companions_label = Label.new()
	companions_label.position = Vector2(12, 10)
	companions_label.size = Vector2(336, 198)
	companions_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	companions_label.text = "동료 정보를 불러오는 중..."
	status_panel.add_child(companions_label)

	fortress_button = Button.new()
	fortress_button.text = "성채 보기"
	fortress_button.position = Vector2(900, 610)
	fortress_button.size = Vector2(170, 40)
	fortress_button.pressed.connect(_on_fortress_button_pressed)
	add_child(fortress_button)

	return_button = Button.new()
	return_button.text = "성채로 돌아가기"
	return_button.position = Vector2(1090, 610)
	return_button.size = Vector2(170, 40)
	return_button.pressed.connect(_on_return_button_pressed)
	add_child(return_button)

	fortress_panel = Panel.new()
	fortress_panel.position = Vector2(900, 660)
	fortress_panel.size = Vector2(360, 56)
	fortress_panel.visible = false
	add_child(fortress_panel)

	fortress_label = Label.new()
	fortress_label.position = Vector2(10, 8)
	fortress_label.size = Vector2(340, 40)
	fortress_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	fortress_panel.add_child(fortress_label)

	event_overlay = ColorRect.new()
	event_overlay.position = Vector2(0, 0)
	event_overlay.size = Vector2(1280, 720)
	event_overlay.color = Color(0, 0, 0, 0.45)
	event_overlay.visible = false
	event_overlay.z_index = 90
	event_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(event_overlay)

	event_panel = Panel.new()
	event_panel.position = Vector2(330, 130)
	event_panel.size = Vector2(660, 430)
	event_panel.visible = false
	event_panel.z_index = 100
	event_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(event_panel)

	event_title_label = Label.new()
	event_title_label.position = Vector2(20, 16)
	event_title_label.size = Vector2(620, 34)
	event_panel.add_child(event_title_label)

	event_speaker_label = Label.new()
	event_speaker_label.position = Vector2(20, 54)
	event_speaker_label.size = Vector2(620, 28)
	event_panel.add_child(event_speaker_label)

	event_dialogue_label = Label.new()
	event_dialogue_label.position = Vector2(20, 92)
	event_dialogue_label.size = Vector2(620, 190)
	event_dialogue_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	event_panel.add_child(event_dialogue_label)

	event_choices_container = VBoxContainer.new()
	event_choices_container.position = Vector2(20, 300)
	event_choices_container.size = Vector2(620, 110)
	event_panel.add_child(event_choices_container)

func spawn_regions() -> void:
	for region_id in GameState.regions.keys():
		var data: Dictionary = GameState.regions[region_id]
		var node: RegionNode = RegionNode.new()
		node.position = data["pos"]
		node.setup(region_id, data["name"], GameState.get_region_owner(region_id), data["adjacent"])
		node.set_region_meta(str(data.get("danger", "보통")), false)
		node.region_clicked.connect(_on_region_clicked)
		add_child(node)
		region_nodes[region_id] = node

func refresh_regions() -> void:
	for region_id in region_nodes.keys():
		var node: RegionNode = region_nodes[region_id]
		var region_name: String = GameState.get_region_name(region_id)
		var is_rumor_target: bool = (GameState.active_rumor_id == "rumor_garon" and region_id == "r2")
		is_rumor_target = is_rumor_target or (GameState.active_rumor_id == "rumor_elin" and region_id == "r3")
		is_rumor_target = is_rumor_target or (GameState.active_rumor_id == "rumor_mira" and region_id == "r7")
		if is_rumor_target:
			node.region_name = region_name
		else:
			node.region_name = region_name
		node.update_owner(GameState.get_region_owner(region_id))
		var region_data: Dictionary = GameState.regions.get(region_id, {})
		node.set_region_meta(str(region_data.get("danger", "보통")), is_rumor_target)
		node.set_selected(region_id == GameState.selected_region_id)
		node.set_attackable(_is_attackable_from_selection(region_id))

func refresh_companions_panel() -> void:
	var lines: Array[String] = ["동료"]
	for companion_variant: Variant in GameState.get_companions_list():
		var companion: Dictionary = companion_variant
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
	lines.append("현재 자원: %s" % GameState.get_resource_summary_text())
	lines.append("강화: 병영 Lv.%d / 훈련장 Lv.%d / 숙소 Lv.%d" % [GameState.barracks_level, GameState.training_ground_level, GameState.lodging_level])
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
	var lines: Array[String] = []
	if GameState.last_battle_message != "":
		lines.append("직전 전투:")
		lines.append(GameState.last_battle_message)
		lines.append("")
	if GameState.active_rumor_id != "":
		var active_rumor: Dictionary = GameState.get_active_rumor()
		if not active_rumor.is_empty():
			lines.append("현재 소문:")
			lines.append(str(active_rumor.get("title", "")))
			lines.append("")
	lines.append("현재 목표:")
	lines.append(_get_current_goal_text())
	lines.append("")
	lines.append("조작:")
	lines.append("청람 지역 선택 → 인접 지역 선택")
	info_label.text = "\n".join(lines)

func refresh_story_event_panel() -> void:
	for child in event_choices_container.get_children():
		child.queue_free()

	if not GameState.has_pending_story_event():
		if story_event_result_active:
			_show_story_result_panel()
			return
		event_panel.visible = false
		event_overlay.visible = false
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
		choice_button.custom_minimum_size = Vector2(620, 38)
		choice_button.pressed.connect(_on_story_choice_selected.bind(i))
		event_choices_container.add_child(choice_button)
	event_overlay.visible = true
	event_panel.visible = true
	# 지역 버튼들이 나중에 add_child 되어도 이벤트 UI가 반드시 맨 위에 오도록 순서를 다시 올립니다.
	move_child(event_overlay, get_child_count() - 1)
	move_child(event_panel, get_child_count() - 1)

func _on_story_choice_selected(choice_index: int) -> void:
	var resolved_event_id: String = GameState.pending_story_event_id
	var recruit_message: String = GameState.resolve_pending_story_event(choice_index)
	_activate_story_result(resolved_event_id, recruit_message)
	refresh_story_event_panel()

func _activate_story_result(event_id: String, recruit_message: String) -> void:
	if recruit_message == "":
		return
	story_event_result_active = true
	if event_id == "recruit_elin":
		story_event_result_speaker = "엘린"
		story_event_result_text = "\"네가 한 말, 쉽게 믿지는 않겠어.\"\n\"하지만 오늘 전장에서 네가 도망치지 않는 건 봤다.\"\n\"서리숲의 길은 내가 열어줄게.\"\n\"엘린. 오늘부터 청람 성채와 함께 싸우겠다.\""
		story_event_join_message = "엘린이 동료로 합류했습니다!"
		story_event_result_battle_message = "엘린이 합류했습니다. 성채로 돌아가 새 동료를 맞이하세요."
	elif event_id == "recruit_mira":
		story_event_result_speaker = "미라"
		story_event_result_text = "\"저… 정말 함께 가도 되는 건가요?\"\n\"아직 완벽한 마법사는 아니지만, 도망치지는 않을게요.\"\n\"이 마법서가 누군가를 다치게 하는 도구가 아니라, 지키는 힘이 되게 만들고 싶어요.\"\n\"미라. 오늘부터 청람 성채에서 배우고, 싸우겠습니다.\""
		story_event_join_message = "미라가 동료로 합류했습니다!"
		if recruit_message.find("소서러 병종이 해금되었습니다!") >= 0:
			story_event_join_message += "\n신규 병종 해금: 소서러"
		story_event_result_battle_message = "미라가 합류했습니다. 성채로 돌아가 새 동료를 맞이하세요."
	else:
		story_event_result_speaker = "가론"
		story_event_result_text = "\"좋다. 네 말이 거짓인지 아닌지는 전장에서 확인하겠다.\"\n\"하지만 적어도, 도망치지 않는 눈은 마음에 드는군.\"\n\"가론. 오늘부터 내 검은 청람의 깃발 아래에 선다.\""
		story_event_join_message = "가론이 동료로 합류했습니다!"
		story_event_result_battle_message = "가론이 합류했습니다. 성채로 돌아가 새 동료를 맞이하세요."

func _show_story_result_panel() -> void:
	for child in event_choices_container.get_children():
		child.queue_free()
	event_title_label.text = "[동료 합류]"
	event_speaker_label.text = "화자: %s" % story_event_result_speaker
	event_dialogue_label.text = "%s\n\n%s" % [story_event_result_text, story_event_join_message]

	var confirm_button: Button = Button.new()
	confirm_button.text = "[확인]"
	confirm_button.custom_minimum_size = Vector2(620, 38)
	confirm_button.pressed.connect(_on_story_result_confirmed)
	event_choices_container.add_child(confirm_button)

	event_overlay.visible = true
	event_panel.visible = true
	move_child(event_overlay, get_child_count() - 1)
	move_child(event_panel, get_child_count() - 1)

func _on_story_result_confirmed() -> void:
	story_event_result_active = false
	GameState.last_battle_message = story_event_result_battle_message
	info_label.text = story_event_result_battle_message
	refresh_companions_panel()
	refresh_fortress_panel()
	refresh_story_event_panel()

func _on_region_clicked(region_id: String) -> void:
	if GameState.has_pending_story_event():
		info_label.text = "진행 중인 동료 이벤트를 먼저 선택하세요."
		return

	var region_owner: int = GameState.get_region_owner(region_id)
	var region_data: Dictionary = GameState.regions.get(region_id, {})
	var danger_text: String = str(region_data.get("danger", "보통"))
	var recommended_text: String = str(region_data.get("recommended", "기본 병력"))
	var encounter_type: String = str(region_data.get("encounter_type", "미상"))
	var reward_preview: String = str(region_data.get("reward_preview", _format_reward_preview(region_data)))
	var enemy_class_preview: String = _format_expected_enemy_classes(region_data)
	var reward_data: Dictionary = region_data.get("reward", {})
	var reward_text: String = GameState.format_reward_text(reward_data)
	var focus_text: String = str(region_data.get("economy_role", ""))
	var suggested_use_text: String = str(region_data.get("suggested_use", ""))
	var select_hint: String = "지역: %s\n위험도: %s\n권장 준비: %s\n전투 유형: %s\n예상 적: %s\n보상 미리보기: %s\n예상 보상: %s" % [GameState.get_region_name(region_id), danger_text, recommended_text, encounter_type, enemy_class_preview, reward_preview, reward_text]
	if focus_text != "":
		select_hint += "\n보상 성격: %s" % focus_text
	if suggested_use_text != "":
		select_hint += "\n활용 팁: %s" % suggested_use_text
	region_detail_label.text = _format_region_detail(region_id, region_data, reward_text, enemy_class_preview)

	if GameState.selected_region_id == "":
		if region_owner != GameState.PLAYER_FACTION:
			info_label.text = "먼저 청람 왕국 소유 지역을 선택하세요."
			refresh_regions()
			return
		GameState.selected_region_id = region_id
		info_label.text = "선택된 지역: %s\n%s\n인접한 적 지역을 선택하세요." % [GameState.regions[region_id]["name"], select_hint]
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
		info_label.text = "아군 지역입니다. 인접한 적 지역을 선택하세요.\n%s" % select_hint
		refresh_regions()
		return

	GameState.set_battle_context(GameState.selected_region_id, region_id)
	info_label.text = "공격 대상: %s\n%s" % [GameState.get_region_name(region_id), select_hint]
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



func _get_current_goal_text() -> String:
	if not GameState.has_companion_joined("garon"):
		return "가론을 찾기 전, 주변 소규모 지역에서 병력을 성장시키세요."
	if not GameState.has_companion_joined("elin"):
		return "서리숲 관문의 숲의 사수를 찾아 전력을 보강하세요."
	if not GameState.has_companion_joined("mira"):
		return "고대 유적지의 견습 마법사를 찾아 마법 전력을 확보하세요."
	return "성채를 정비하고 다음 원정을 준비하세요."

func _format_reward_preview(region_data: Dictionary) -> String:
	var reward_data: Dictionary = region_data.get("reward", {})
	return GameState.format_reward_text(reward_data)

func _format_region_detail(region_id: String, region_data: Dictionary, reward_text: String, enemy_preview: String) -> String:
	var lines: Array[String] = []
	lines.append("지역: %s" % GameState.get_region_name(region_id))
	lines.append("세력: %s" % GameState.FACTION_NAMES.get(GameState.get_region_owner(region_id), "미상"))
	lines.append("위험도: %s" % str(region_data.get("danger", "보통")))
	lines.append("권장 준비: %s" % str(region_data.get("recommended", "기본 병력")))
	lines.append("전투 유형: %s" % str(region_data.get("encounter_type", "미상")))
	lines.append("예상 적 병종: %s" % enemy_preview)
	lines.append("획득 보상: %s" % reward_text)
	lines.append("보상 성격: %s" % str(region_data.get("economy_role", "일반")))
	lines.append("활용 팁: %s" % str(region_data.get("suggested_use", "전력을 점검하고 출정하세요.")))
	if region_data.has("unlock_class"):
		lines.append("해금 요소: %s" % str(region_data.get("unlock_class", "")))
	return "\n".join(lines)

func create_route_lines() -> void:
	var line_layer: Node2D = Node2D.new()
	line_layer.z_index = -20
	add_child(line_layer)
	var drawn_edges: Dictionary = {}
	for region_id_variant: Variant in GameState.regions.keys():
		var region_id: String = str(region_id_variant)
		var region_data: Dictionary = GameState.regions.get(region_id, {})
		var from_pos: Vector2 = region_data.get("pos", Vector2.ZERO) + Vector2(80, 38)
		for adjacent_variant: Variant in region_data.get("adjacent", []):
			var adjacent_id: String = str(adjacent_variant)
			var edge_a: String = "%s-%s" % [region_id, adjacent_id]
			var edge_b: String = "%s-%s" % [adjacent_id, region_id]
			if drawn_edges.has(edge_a) or drawn_edges.has(edge_b):
				continue
			var adjacent_data: Dictionary = GameState.regions.get(adjacent_id, {})
			if adjacent_data.is_empty():
				continue
			var to_pos: Vector2 = adjacent_data.get("pos", Vector2.ZERO) + Vector2(80, 38)
			var route_line: Line2D = Line2D.new()
			route_line.default_color = Color(0.8, 0.82, 0.9, 0.35)
			route_line.width = 2.0
			route_line.add_point(from_pos)
			route_line.add_point(to_pos)
			line_layer.add_child(route_line)
			drawn_edges[edge_a] = true

func _format_expected_enemy_classes(region_data: Dictionary) -> String:
	var names: Array[String] = []
	for class_variant: Variant in region_data.get("expected_enemy_classes", []):
		var class_id: String = str(class_variant)
		var class_data: Dictionary = GameState.UNIT_CLASSES.get(class_id, {})
		names.append(str(class_data.get("display_name", class_id)))
	if names.is_empty():
		return "정보 없음"
	return ", ".join(names)

func _on_return_button_pressed() -> void:
	GameState.clear_selection()
	get_tree().change_scene_to_file("res://scenes/CastleHub.tscn")
