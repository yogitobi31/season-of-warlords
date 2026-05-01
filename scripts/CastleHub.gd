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
	get_tree().change_scene_to_file("res://scenes/WorldMap.tscn")

func _on_rumor_pressed() -> void:
	refresh_rumor_panel()
	rumor_overlay.visible = true

func _on_leon_pressed() -> void:
	dialogue_speaker_label.text = "레온"
	if GameState.has_companion_joined("garon"):
		dialogue_text_label.text = "주군, 가론이 성문 쪽 순찰을 맡고 있습니다. 다음 출정을 준비하죠."
	else:
		dialogue_text_label.text = "주군, 북부 감시요새에 이상한 소문이 돌고 있습니다."
	dialogue_panel.visible = true

func _on_garon_pressed() -> void:
	if not GameState.has_companion_joined("garon"):
		return
	dialogue_speaker_label.text = "가론"
	dialogue_text_label.text = "성채가 낡았어도 깃발은 살아 있군. 다음 원정에서 내 정찰대를 붙이겠다."
	dialogue_panel.visible = true

func _on_dialogue_confirm_pressed() -> void:
	dialogue_panel.visible = false

func _on_companion_popup_pressed() -> void:
	show_popup("동료 보기", build_companion_text())

func _on_manage_popup_pressed() -> void:
	show_popup("성채 관리", build_facilities_text() + "\n\n" + build_castle_people_text())

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
	if GameState.pending_castle_event_id == "garon_arrival":
		GameState.complete_castle_event("garon_arrival")
	refresh_castle_event_panel()
	refresh_rumor_panel()
	refresh_quest_log()
	refresh_courtyard_people()
