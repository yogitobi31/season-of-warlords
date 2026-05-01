extends Control

@onready var quest_log_label: Label = $UILayer/QuestLogPanel/QuestLogLabel
@onready var status_label: Label = $UILayer/StatusLabel
@onready var dialogue_panel: Panel = $UILayer/DialoguePanel
@onready var dialogue_speaker_label: Label = $UILayer/DialoguePanel/DialogueMargin/DialogueVBox/SpeakerNameLabel
@onready var dialogue_text_label: Label = $UILayer/DialoguePanel/DialogueMargin/DialogueVBox/DialogueTextLabel
@onready var dialogue_confirm_button: Button = $UILayer/DialoguePanel/DialogueMargin/DialogueVBox/DialogueConfirmButton

@onready var leon_marker: Panel = $SceneRoot/LeonMarker
@onready var garon_marker: Panel = $SceneRoot/GaronMarker
@onready var leon_button: Button = $SceneRoot/LeonMarker/LeonButton
@onready var garon_button: Button = $SceneRoot/GaronMarker/GaronButton
@onready var gate_button: Button = $SceneRoot/Gate/GateButton
@onready var rumor_board_button: Button = $SceneRoot/RumorBoard/RumorBoardButton

@onready var rumor_button: Button = $UILayer/TopMenu/RumorButton
@onready var companion_button: Button = $UILayer/TopMenu/CompanionButton
@onready var manage_button: Button = $UILayer/TopMenu/ManageButton

@onready var info_popup_overlay: Control = $UILayer/InfoPopupOverlay
@onready var popup_title_label: Label = $UILayer/InfoPopupOverlay/PopupPanel/PopupMargin/PopupVBox/PopupTitleLabel
@onready var popup_body_label: Label = $UILayer/InfoPopupOverlay/PopupPanel/PopupMargin/PopupVBox/PopupBodyLabel
@onready var popup_vbox: VBoxContainer = $UILayer/InfoPopupOverlay/PopupPanel/PopupMargin/PopupVBox
@onready var popup_close_button: Button = $UILayer/InfoPopupOverlay/PopupPanel/PopupMargin/PopupVBox/PopupCloseButton

@onready var rumor_overlay: Control = $UILayer/RumorOverlay
@onready var rumor_title_label: Label = $UILayer/RumorOverlay/RumorPanel/RumorMargin/RumorVBox/RumorTitleLabel
@onready var rumor_body_label: Label = $UILayer/RumorOverlay/RumorPanel/RumorMargin/RumorVBox/RumorBodyLabel
@onready var rumor_track_button: Button = $UILayer/RumorOverlay/RumorPanel/RumorMargin/RumorVBox/RumorButtonsHBox/TrackRumorButton
@onready var rumor_close_button: Button = $UILayer/RumorOverlay/RumorPanel/RumorMargin/RumorVBox/RumorButtonsHBox/CloseRumorButton

@onready var castle_event_overlay: Control = $UILayer/CastleEventOverlay
@onready var castle_event_speaker_label: Label = $UILayer/CastleEventOverlay/CastleEventPanel/Margin/VBox/SpeakerLabel
@onready var castle_event_dialogue_label: Label = $UILayer/CastleEventOverlay/CastleEventPanel/Margin/VBox/DialogueLabel
@onready var castle_event_confirm_button: Button = $UILayer/CastleEventOverlay/CastleEventPanel/Margin/VBox/ConfirmButton

var rumor_panel_rumor_id: String = ""
var opening_lines: Array[String] = []
var opening_index: int = 0
var opening_active: bool = false
var upgrade_barracks_button: Button
var upgrade_training_button: Button
var upgrade_lodging_button: Button

func _ready() -> void:
	build_character_markers()
	refresh_quest_log()
	refresh_status_message()
	refresh_rumor_panel()
	refresh_courtyard_people()
	GameState.update_pending_castle_event()
	refresh_castle_event_panel()

	gate_button.pressed.connect(_on_expedition_pressed)
	rumor_board_button.pressed.connect(_on_rumor_pressed)
	leon_button.pressed.connect(_on_leon_pressed)
	garon_button.pressed.connect(_on_garon_pressed)
	rumor_button.pressed.connect(_on_rumor_pressed)
	companion_button.pressed.connect(_on_companion_popup_pressed)
	manage_button.pressed.connect(_on_manage_popup_pressed)
	popup_close_button.pressed.connect(_on_close_info_popup_pressed)
	rumor_track_button.pressed.connect(_on_track_rumor_pressed)
	rumor_close_button.pressed.connect(_on_close_rumor_pressed)
	castle_event_confirm_button.pressed.connect(_on_castle_event_confirm_pressed)
	dialogue_confirm_button.pressed.connect(_on_dialogue_confirm_pressed)
	setup_opening_lines()
	setup_manage_buttons()
	start_opening_if_needed()

func setup_manage_buttons() -> void:
	upgrade_barracks_button = Button.new()
	upgrade_barracks_button.text = "병영 강화"
	upgrade_barracks_button.custom_minimum_size = Vector2(0, 34)
	upgrade_barracks_button.pressed.connect(_on_upgrade_barracks_pressed)
	popup_vbox.add_child(upgrade_barracks_button)

	upgrade_training_button = Button.new()
	upgrade_training_button.text = "훈련장 강화"
	upgrade_training_button.custom_minimum_size = Vector2(0, 34)
	upgrade_training_button.pressed.connect(_on_upgrade_training_pressed)
	popup_vbox.add_child(upgrade_training_button)

	upgrade_lodging_button = Button.new()
	upgrade_lodging_button.text = "숙소 강화"
	upgrade_lodging_button.custom_minimum_size = Vector2(0, 34)
	upgrade_lodging_button.pressed.connect(_on_upgrade_lodging_pressed)
	popup_vbox.add_child(upgrade_lodging_button)

func create_character_sprite(character_name: String, character_title: String, body_color: Color) -> Control:
	var root: Control = Control.new()
	root.custom_minimum_size = Vector2(130, 130)

	var feet: ColorRect = ColorRect.new()
	feet.color = body_color.darkened(0.35)
	feet.position = Vector2(47, 56)
	feet.size = Vector2(36, 12)
	root.add_child(feet)

	var body: ColorRect = ColorRect.new()
	body.color = body_color
	body.position = Vector2(43, 30)
	body.size = Vector2(44, 32)
	root.add_child(body)

	var head: ColorRect = ColorRect.new()
	head.color = Color(0.88, 0.78, 0.63, 1)
	head.position = Vector2(50, 10)
	head.size = Vector2(30, 20)
	root.add_child(head)

	var name_label: Label = Label.new()
	name_label.text = character_name
	name_label.position = Vector2(0, 82)
	name_label.size = Vector2(130, 22)
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(name_label)

	var title_label: Label = Label.new()
	title_label.text = character_title
	title_label.position = Vector2(0, 102)
	title_label.size = Vector2(130, 20)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 13)
	root.add_child(title_label)

	return root

func build_character_markers() -> void:
	for child: Node in leon_marker.get_children():
		if child != leon_button:
			child.queue_free()
	for child: Node in garon_marker.get_children():
		if child != garon_button:
			child.queue_free()
	leon_marker.add_child(create_character_sprite("레온", "청람 기사", Color(0.2, 0.38, 0.8, 1)))
	garon_marker.add_child(create_character_sprite("가론", "용병대장", Color(0.46, 0.28, 0.2, 1)))
	leon_marker.move_child(leon_button, leon_marker.get_child_count() - 1)
	garon_marker.move_child(garon_button, garon_marker.get_child_count() - 1)

func _on_expedition_pressed() -> void:
	if opening_active:
		return
	get_tree().change_scene_to_file("res://scenes/WorldMap.tscn")

func _on_rumor_pressed() -> void:
	if opening_active:
		return
	refresh_rumor_panel()
	rumor_overlay.visible = true

func _on_leon_pressed() -> void:
	if opening_active:
		return
	dialogue_speaker_label.text = "레온"
	if GameState.has_companion_joined("garon"):
		dialogue_text_label.text = "주군, 가론이 성문 쪽 순찰을 맡고 있습니다. 다음 출정을 준비하죠."
	else:
		dialogue_text_label.text = "주군, 북부 감시요새에 이상한 소문이 돌고 있습니다."
	dialogue_panel.visible = true

func _on_garon_pressed() -> void:
	if opening_active:
		return
	if not GameState.has_companion_joined("garon"):
		return
	dialogue_speaker_label.text = "가론"
	dialogue_text_label.text = "성채가 낡았어도 깃발은 살아 있군. 다음 원정에서 내 정찰대를 붙이겠다."
	dialogue_panel.visible = true

func _on_dialogue_confirm_pressed() -> void:
	if opening_active:
		advance_opening()
		return
	dialogue_panel.visible = false

func _on_companion_popup_pressed() -> void:
	if opening_active:
		return
	show_popup("동료 보기", build_companion_text())

func _on_manage_popup_pressed() -> void:
	if opening_active:
		return
	show_popup("성채 관리", build_manage_text())

func show_popup(title: String, body: String) -> void:
	popup_title_label.text = title
	popup_body_label.text = body
	info_popup_overlay.visible = true

func _on_close_info_popup_pressed() -> void:
	info_popup_overlay.visible = false

func build_companion_text() -> String:
	var lines: Array[String] = ["동료 목록"]
	for companion_data: Dictionary in GameState.get_companions_list():
		var joined: bool = bool(companion_data.get("joined", false))
		if joined:
			lines.append("[합류] %s Lv.%d EXP %d/100" % [str(companion_data.get("name", "?")), int(companion_data.get("level", 1)), int(companion_data.get("exp", 0))])
		else:
			lines.append("[미합류] %s" % str(companion_data.get("name", "?")))
	return "\n".join(lines)

func build_facilities_text() -> String:
	var fortress_data: Dictionary = GameState.fortress_data
	var lines: Array[String] = ["시설", "%s Lv.%d" % [str(fortress_data.get("name", "성채")), int(fortress_data.get("level", 1))], ""]
	var facilities: Array = fortress_data.get("facilities", [])
	for facility_variant: Variant in facilities:
		var facility: Dictionary = facility_variant
		lines.append("- %s Lv.%d" % [str(facility.get("name", "시설")), int(facility.get("level", 0))])
	return "\n".join(lines)

func build_manage_text() -> String:
	var cost_barracks: Dictionary = GameState.get_upgrade_cost("barracks")
	var cost_training: Dictionary = GameState.get_upgrade_cost("training_ground")
	var cost_lodging: Dictionary = GameState.get_upgrade_cost("lodging")
	var lines: Array[String] = []
	lines.append("현재 자원:")
	lines.append("- 금화: %d" % GameState.gold)
	lines.append("- 보급: %d" % GameState.supplies)
	lines.append("- 자재: %d" % GameState.materials)
	lines.append("- 명성: %d" % GameState.renown)
	lines.append("")
	lines.append("자원 설명:")
	lines.append("- 금화: 훈련과 장비의 기본 화폐")
	lines.append("- 보급: 출정과 회복의 유지 자원")
	lines.append("- 자재: 성채와 장비 강화 자원")
	lines.append("- 명성: 사람들의 신뢰와 해금 조건")
	lines.append("")
	lines.append("시설:")
	lines.append("- 병영 Lv.%d" % GameState.barracks_level)
	lines.append("- 훈련장 Lv.%d" % GameState.training_ground_level)
	lines.append("- 숙소 Lv.%d" % GameState.lodging_level)
	lines.append("")
	lines.append("업그레이드 비용")
	lines.append("- 병영 Lv.%d (다음 비용 Gold %d / 재료 %d)" % [GameState.barracks_level, int(cost_barracks.get("gold", 0)), int(cost_barracks.get("materials", 0))])
	lines.append("- 훈련장 Lv.%d (다음 비용 Gold %d / 재료 %d)" % [GameState.training_ground_level, int(cost_training.get("gold", 0)), int(cost_training.get("materials", 0))])
	lines.append("- 숙소 Lv.%d (다음 비용 Gold %d / 재료 %d)" % [GameState.lodging_level, int(cost_lodging.get("gold", 0)), int(cost_lodging.get("materials", 0))])
	lines.append("")
	lines.append("다음 추천:")
	if GameState.barracks_level < 2:
		lines.append("- 북부 감시요새 전에는 병영 Lv.2를 추천합니다.")
	if not GameState.is_unit_class_unlocked("shieldbearer"):
		lines.append("- 무너진 초소를 점령하면 방패보병을 해금할 수 있습니다.")
	if not GameState.is_unit_class_unlocked("spearman"):
		lines.append("- 낡은 훈련장을 정리하면 창병을 해금할 수 있습니다.")
	lines.append("")
	lines.append(build_facilities_text())
	lines.append("")
	lines.append(build_castle_people_text())
	return "\n".join(lines)

func _on_upgrade_barracks_pressed() -> void:
	_try_upgrade("barracks")

func _on_upgrade_training_pressed() -> void:
	_try_upgrade("training_ground")

func _on_upgrade_lodging_pressed() -> void:
	_try_upgrade("lodging")

func _try_upgrade(upgrade_key: String) -> void:
	var success: bool = GameState.try_upgrade_castle(upgrade_key)
	if success:
		popup_title_label.text = "성채 관리 (강화 성공)"
	else:
		popup_title_label.text = "성채 관리 (자원 부족)"
	popup_body_label.text = build_manage_text()

func build_castle_people_text() -> String:
	var lines: Array[String] = ["성채 인물"]
	for companion_data: Dictionary in GameState.get_joined_companions():
		lines.append("- %s" % str(companion_data.get("name", "?")))
	return "\n".join(lines)

func refresh_quest_log() -> void:
	if GameState.has_companion_joined("garon"):
		quest_log_label.text = "현재 목표:\n서리숲 관문의 숲의 사수 소문을 조사하라"
	else:
		quest_log_label.text = "현재 목표:\n북부 감시요새의 가론을 찾아라"

func refresh_status_message() -> void:
	if GameState.active_rumor_id == "rumor_garon":
		status_label.text = "가론의 소문을 추적 중입니다. 성문을 클릭해 출정하세요."
		return
	if GameState.active_rumor_id == "rumor_elin":
		status_label.text = "숲의 사수 소문을 추적 중입니다."
		return
	status_label.text = ""

func refresh_rumor_panel() -> void:
	var available_ids: Array[String] = GameState.get_available_rumor_ids()
	if available_ids.is_empty():
		rumor_panel_rumor_id = ""
		rumor_title_label.text = "추적 가능한 소문이 없습니다."
		rumor_body_label.text = "지금은 성채 정비와 동료 대화에 집중하세요."
		rumor_track_button.disabled = true
		return
	rumor_panel_rumor_id = available_ids[0]
	var rumor_data: Dictionary = GameState.rumors.get(rumor_panel_rumor_id, {})
	rumor_title_label.text = str(rumor_data.get("title", "소문"))
	var body_text: String = ""
	if rumor_panel_rumor_id == "rumor_garon":
		body_text = "\"북부 감시요새에는 진홍 공국의 명령을 따르지 않고, 백성들을 지키는 용병대장이 있다는 소문이 있습니다.\"\n"
		body_text += "\"그의 이름은 가론. 약자를 버리는 군주는 따르지 않는다고 합니다.\""
	else:
		body_text = "\"서리숲 관문 근처에서 진홍 공국의 정찰대를 홀로 막아내는 사수가 있다는 소문이 있습니다.\"\n"
		body_text += "\"그녀는 숲을 지키기 위해 누구의 깃발도 따르지 않는다고 합니다.\"\n\n관련 동료: 엘린"
	if bool(rumor_data.get("completed", false)):
		body_text += "\n\n(이미 해결한 소문입니다.)"
	rumor_body_label.text = body_text
	rumor_track_button.disabled = bool(rumor_data.get("completed", false))

func _on_track_rumor_pressed() -> void:
	if opening_active:
		return
	if rumor_panel_rumor_id != "" and GameState.track_rumor(rumor_panel_rumor_id):
		refresh_status_message()
	rumor_overlay.visible = false

func _on_close_rumor_pressed() -> void:
	rumor_overlay.visible = false

func refresh_courtyard_people() -> void:
	garon_marker.visible = GameState.has_companion_joined("garon")

func refresh_castle_event_panel() -> void:
	if GameState.pending_castle_event_id != "garon_arrival":
		castle_event_overlay.visible = false
		return
	castle_event_speaker_label.text = "레온 / 가론"
	castle_event_dialogue_label.text = "레온:\n\"주군, 북부 감시요새에서 데려온 용병대장이 도착했습니다.\"\n\n가론:\n\"여기가 청람 성채인가.\"\n\"생각보다 낡았군. 병사들도 지쳐 있고.\"\n\n레온:\n\"말은 조심하는 게 좋을 거다.\"\n\n가론:\n\"하지만 깃발은 아직 내려가지 않았군.\"\n\"좋다. 적어도 이곳에는 아직 싸울 이유가 남아 있어.\"\n\n레온:\n\"주군, 가론이 합류한 것은 큰 힘이 될 겁니다.\"\n\n가론이 청람 성채에 합류했습니다."
	castle_event_overlay.visible = true

func _on_castle_event_confirm_pressed() -> void:
	if opening_active:
		return
	if GameState.pending_castle_event_id == "garon_arrival":
		GameState.complete_castle_event("garon_arrival")
	refresh_castle_event_panel()
	refresh_rumor_panel()
	refresh_quest_log()
	refresh_courtyard_people()

func setup_opening_lines() -> void:
	opening_lines = [
		"오래전, 청람 왕국은 북방의 작은 성채 하나만을 남긴 채 무너졌다.",
		"진홍 공국의 깃발은 날마다 가까워지고, 성채의 병사들은 지쳐 있었다.",
		"하지만 아직 청람의 깃발은 내려가지 않았다.",
		"레온: 주군, 이곳은 낡았지만 아직 끝난 곳은 아닙니다.",
		"레온: 소문을 따라 사람을 모으고, 전장에서 믿음을 증명해야 합니다.",
		"청람 성채에서 새로운 군웅의 계절이 시작된다."
	]

func start_opening_if_needed() -> void:
	if GameState.opening_seen:
		return
	opening_active = true
	opening_index = 0
	dialogue_panel.visible = true
	dialogue_speaker_label.text = "청람의 기록"
	dialogue_confirm_button.text = "계속"
	show_opening_line()

func show_opening_line() -> void:
	if opening_index < 0 or opening_index >= opening_lines.size():
		return
	dialogue_text_label.text = opening_lines[opening_index]
	if opening_index == opening_lines.size() - 1:
		dialogue_confirm_button.text = "시작"
	else:
		dialogue_confirm_button.text = "계속"

func advance_opening() -> void:
	opening_index += 1
	if opening_index >= opening_lines.size():
		end_opening()
		return
	show_opening_line()

func end_opening() -> void:
	opening_active = false
	GameState.opening_seen = true
	dialogue_panel.visible = false
	dialogue_confirm_button.text = "확인"
