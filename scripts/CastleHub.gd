extends Control

@onready var companions_label: Label = $MainMargin/MainVBox/CenterHBox/SideInfoVBox/CompanionsPanel/CompanionsLabel
@onready var facilities_label: Label = $MainMargin/MainVBox/CenterHBox/SideInfoVBox/FacilitiesPanel/FacilitiesLabel
@onready var castle_people_label: Label = $MainMargin/MainVBox/CenterHBox/SideInfoVBox/CastlePeoplePanel/CastlePeopleLabel
@onready var chapter_progress_label: Label = $MainMargin/MainVBox/BottomPanel/BottomMargin/BottomVBox/ChapterProgressPanel/ChapterProgressLabel
@onready var status_label: Label = $MainMargin/MainVBox/BottomPanel/BottomMargin/BottomVBox/StatusLabel
@onready var dialogue_speaker_label: Label = $MainMargin/MainVBox/BottomPanel/BottomMargin/BottomVBox/RpgDialoguePanel/RpgDialogueMargin/RpgDialogueVBox/DialogueTopHBox/SpeakerNameLabel
@onready var leon_dialogue_label: Label = $MainMargin/MainVBox/BottomPanel/BottomMargin/BottomVBox/RpgDialoguePanel/RpgDialogueMargin/RpgDialogueVBox/DialogueTextLabel
@onready var dialogue_confirm_button: Button = $MainMargin/MainVBox/BottomPanel/BottomMargin/BottomVBox/RpgDialoguePanel/RpgDialogueMargin/RpgDialogueVBox/DialogueBottomHBox/DialogueConfirmButton
@onready var courtyard: Control = $MainMargin/MainVBox/CenterHBox/ScenePanel/Courtyard
@onready var leon_marker: Control = $MainMargin/MainVBox/CenterHBox/ScenePanel/Courtyard/LeonMarker
@onready var garon_marker: Control = $MainMargin/MainVBox/CenterHBox/ScenePanel/Courtyard/GaronMarker
@onready var gate_button: Button = $MainMargin/MainVBox/CenterHBox/ScenePanel/Courtyard/GatePlaceholder/GateButton
@onready var rumor_board_button: Button = $MainMargin/MainVBox/CenterHBox/ScenePanel/Courtyard/RumorBoard/RumorBoardButton
@onready var expedition_button: Button = $MainMargin/MainVBox/BottomPanel/BottomMargin/BottomVBox/ButtonsHBox/ExpeditionButton
@onready var rumor_button: Button = $MainMargin/MainVBox/BottomPanel/BottomMargin/BottomVBox/ButtonsHBox/RumorButton
@onready var companion_button: Button = $MainMargin/MainVBox/BottomPanel/BottomMargin/BottomVBox/ButtonsHBox/CompanionButton
@onready var manage_button: Button = $MainMargin/MainVBox/BottomPanel/BottomMargin/BottomVBox/ButtonsHBox/ManageButton
@onready var rest_button: Button = $MainMargin/MainVBox/BottomPanel/BottomMargin/BottomVBox/ButtonsHBox/RestButton
@onready var rumor_overlay: Control = $RumorOverlay
@onready var rumor_title_label: Label = $RumorOverlay/Center/RumorPanel/RumorMargin/RumorVBox/RumorCardPanel/RumorCardMargin/RumorCardVBox/RumorTitleLabel
@onready var rumor_body_label: Label = $RumorOverlay/Center/RumorPanel/RumorMargin/RumorVBox/RumorCardPanel/RumorCardMargin/RumorCardVBox/RumorContentHBox/RumorScroll/RumorBodyLabel
@onready var rumor_track_button: Button = $RumorOverlay/Center/RumorPanel/RumorMargin/RumorVBox/RumorButtonsHBox/TrackRumorButton
@onready var rumor_close_button: Button = $RumorOverlay/Center/RumorPanel/RumorMargin/RumorVBox/RumorButtonsHBox/CloseRumorButton
@onready var castle_event_overlay: Control = $CastleEventOverlay
@onready var castle_event_speaker_label: Label = $CastleEventOverlay/Center/CastleEventPanel/Margin/VBox/SpeakerLabel
@onready var castle_event_dialogue_label: Label = $CastleEventOverlay/Center/CastleEventPanel/Margin/VBox/DialogueLabel
@onready var castle_event_confirm_button: Button = $CastleEventOverlay/Center/CastleEventPanel/Margin/VBox/ConfirmButton

var rumor_panel_rumor_id: String = ""

func _ready() -> void:
	refresh_companions()
	refresh_facilities()
	refresh_castle_people()
	refresh_chapter_progress()
	refresh_status_message()
	refresh_rumor_panel()
	refresh_dialogue_box()
	refresh_courtyard_people()
	GameState.update_pending_castle_event()
	refresh_castle_event_panel()
	expedition_button.pressed.connect(_on_expedition_pressed)
	rumor_button.pressed.connect(_on_rumor_pressed)
	companion_button.pressed.connect(_on_coming_soon_pressed.bind("동료 보기"))
	manage_button.pressed.connect(_on_coming_soon_pressed.bind("성채 관리"))
	rest_button.pressed.connect(_on_coming_soon_pressed.bind("휴식하기"))
	rumor_track_button.pressed.connect(_on_track_rumor_pressed)
	rumor_close_button.pressed.connect(_on_close_rumor_pressed)
	castle_event_confirm_button.pressed.connect(_on_castle_event_confirm_pressed)
	dialogue_confirm_button.pressed.connect(_on_dialogue_confirm_pressed)
	gate_button.pressed.connect(_on_expedition_pressed)
	rumor_board_button.pressed.connect(_on_rumor_pressed)
	leon_marker.gui_input.connect(_on_leon_marker_gui_input)
	garon_marker.gui_input.connect(_on_garon_marker_gui_input)
	build_character_markers()


func create_character_sprite(name: String, title: String, body_color: Color) -> Control:
	var root: Control = Control.new()
	root.custom_minimum_size = Vector2(120, 128)

	var feet: ColorRect = ColorRect.new()
	feet.color = body_color.darkened(0.35)
	feet.position = Vector2(44, 56)
	feet.size = Vector2(32, 12)
	root.add_child(feet)

	var body: ColorRect = ColorRect.new()
	body.color = body_color
	body.position = Vector2(40, 30)
	body.size = Vector2(40, 32)
	root.add_child(body)

	var head: ColorRect = ColorRect.new()
	head.color = Color(0.88, 0.78, 0.63, 1)
	head.position = Vector2(46, 10)
	head.size = Vector2(28, 20)
	root.add_child(head)

	var name_label: Label = Label.new()
	name_label.text = name
	name_label.position = Vector2(0, 78)
	name_label.size = Vector2(120, 22)
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(name_label)

	var title_label: Label = Label.new()
	title_label.text = title
	title_label.position = Vector2(0, 98)
	title_label.size = Vector2(120, 20)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 13)
	root.add_child(title_label)

	return root

func build_character_markers() -> void:
	for child: Node in leon_marker.get_children():
		child.queue_free()
	for child: Node in garon_marker.get_children():
		child.queue_free()
	leon_marker.add_child(create_character_sprite("레온", "청람 기사", Color(0.2, 0.38, 0.8, 1)))
	garon_marker.add_child(create_character_sprite("가론", "용병대장", Color(0.46, 0.28, 0.2, 1)))

func _on_leon_marker_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_on_coming_soon_pressed("동료 보기")

func _on_garon_marker_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_on_coming_soon_pressed("동료 보기")

func refresh_companions() -> void:
	var lines: Array[String] = ["동료 목록"]
	for companion_data: Dictionary in GameState.get_companions_list():
		var joined: bool = bool(companion_data.get("joined", false))
		if joined:
			lines.append("[합류] %s Lv.%d EXP %d/100" % [
				str(companion_data.get("name", "?")),
				int(companion_data.get("level", 1)),
				int(companion_data.get("exp", 0))
			])
		else:
			lines.append("[미합류] %s" % [
				str(companion_data.get("name", "?")),
			])
	companions_label.text = "\n".join(lines)

func refresh_facilities() -> void:
	var fortress_data: Dictionary = GameState.fortress_data
	var lines: Array[String] = ["시설", "%s Lv.%d" % [str(fortress_data.get("name", "성채")), int(fortress_data.get("level", 1))], ""]
	var facilities: Array = fortress_data.get("facilities", [])
	for facility_variant: Variant in facilities:
		var facility: Dictionary = facility_variant
		lines.append("- %s Lv.%d" % [str(facility.get("name", "시설")), int(facility.get("level", 0))])
	facilities_label.text = "\n".join(lines)

func refresh_status_message() -> void:
	if GameState.active_rumor_id == "rumor_garon":
		status_label.text = "가론의 소문을 추적합니다. 북부 감시요새로 출정하세요."
		return
	if GameState.active_rumor_id == "rumor_elin":
		status_label.text = "숲의 사수 소문을 추적합니다. 서리숲 관문을 조사하세요."
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
		body_text += "\"그의 이름은 가론. 돈으로 움직이는 자처럼 보이지만, 약자를 버리는 군주는 따르지 않는다고 합니다.\""
	else:
		body_text = "\"서리숲 관문 근처에서 진홍 공국의 정찰대를 홀로 막아내는 사수가 있다는 소문이 있습니다.\"\n"
		body_text += "\"그녀는 숲을 지키기 위해 누구의 깃발도 따르지 않는다고 합니다.\"\n\n관련 동료: 엘린"
	if bool(rumor_data.get("completed", false)):
		body_text += "\n\n(이미 해결한 소문입니다.)"
	rumor_body_label.text = body_text
	var can_track: bool = not bool(rumor_data.get("completed", false))
	rumor_track_button.disabled = not can_track

func _on_expedition_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/WorldMap.tscn")

func _on_rumor_pressed() -> void:
	refresh_rumor_panel()
	rumor_overlay.visible = true

func _on_track_rumor_pressed() -> void:
	if rumor_panel_rumor_id != "" and GameState.track_rumor(rumor_panel_rumor_id):
		refresh_status_message()
	rumor_overlay.visible = false

func _on_close_rumor_pressed() -> void:
	rumor_overlay.visible = false

func _on_coming_soon_pressed(feature_name: String) -> void:
	status_label.text = "%s: 준비 중입니다." % feature_name

func refresh_castle_people() -> void:
	var lines: Array[String] = ["성채 인물"]
	for companion_data: Dictionary in GameState.get_joined_companions():
		lines.append("- %s" % str(companion_data.get("name", "?")))
	castle_people_label.text = "\n".join(lines)

func refresh_chapter_progress() -> void:
	var lines: Array[String] = ["1장: 청람 성채의 깃발", "", "현재 목표:"]
	if GameState.has_companion_joined("garon"):
		lines.append("서리숲 관문의 숲의 사수에 대한 소문을 조사하세요.")
	else:
		lines.append("가론의 소문을 추적합니다.\n북부 감시요새로 출정하세요.")
	chapter_progress_label.text = "\n".join(lines)

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
	refresh_chapter_progress()
	refresh_castle_people()


func refresh_dialogue_box() -> void:
	dialogue_speaker_label.text = "레온"
	if GameState.has_companion_joined("garon"):
		leon_dialogue_label.text = "주군, 가론이 성문 쪽 순찰을 맡고 있습니다. 다음 출정을 준비하죠."
		return
	leon_dialogue_label.text = "주군, 북부 감시요새에 이상한 소문이 돌고 있습니다."

func refresh_courtyard_people() -> void:
	garon_marker.visible = GameState.has_companion_joined("garon")

func _on_dialogue_confirm_pressed() -> void:
	refresh_dialogue_box()
