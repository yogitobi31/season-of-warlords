extends Control

@onready var companions_label: Label = $MainMargin/MainVBox/TopHBox/SideInfoVBox/CompanionsPanel/CompanionsLabel
@onready var facilities_label: Label = $MainMargin/MainVBox/TopHBox/SideInfoVBox/FacilitiesPanel/FacilitiesLabel
@onready var status_label: Label = $MainMargin/MainVBox/BottomPanel/BottomMargin/BottomVBox/StatusLabel
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

func _ready() -> void:
	refresh_companions()
	refresh_facilities()
	refresh_status_message()
	refresh_rumor_panel()
	expedition_button.pressed.connect(_on_expedition_pressed)
	rumor_button.pressed.connect(_on_rumor_pressed)
	companion_button.pressed.connect(_on_coming_soon_pressed.bind("동료 보기"))
	manage_button.pressed.connect(_on_coming_soon_pressed.bind("성채 관리"))
	rest_button.pressed.connect(_on_coming_soon_pressed.bind("휴식하기"))
	rumor_track_button.pressed.connect(_on_track_rumor_pressed)
	rumor_close_button.pressed.connect(_on_close_rumor_pressed)

func refresh_companions() -> void:
	var lines: Array[String] = ["동료 목록"]
	for companion_data: Dictionary in GameState.get_companions_list():
		var joined: bool = bool(companion_data.get("joined", false))
		if joined:
			lines.append("- %s (%s) Lv.%d EXP %d/100" % [
				str(companion_data.get("name", "?")),
				str(companion_data.get("title", "")),
				int(companion_data.get("level", 1)),
				int(companion_data.get("exp", 0))
			])
		else:
			lines.append("- %s (%s) 미합류" % [
				str(companion_data.get("name", "?")),
				str(companion_data.get("title", ""))
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
	status_label.text = ""

func refresh_rumor_panel() -> void:
	var rumor_data: Dictionary = GameState.rumors.get("rumor_garon", {})
	rumor_title_label.text = "북부 감시요새의 용병대장"
	var body_text: String = "\"북부 감시요새에는 진홍 공국의 명령을 따르지 않고, 백성들을 지키는 용병대장이 있다는 소문이 있습니다.\"\n"
	body_text += "\"그의 이름은 가론. 돈으로 움직이는 자처럼 보이지만, 약자를 버리는 군주는 따르지 않는다고 합니다.\""
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
	if GameState.track_rumor("rumor_garon"):
		status_label.text = "가론의 소문을 추적합니다. 북부 감시요새로 출정하세요."
	rumor_overlay.visible = false

func _on_close_rumor_pressed() -> void:
	rumor_overlay.visible = false

func _on_coming_soon_pressed(feature_name: String) -> void:
	status_label.text = "%s: 준비 중입니다." % feature_name
