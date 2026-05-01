extends Control

@onready var companions_label: Label = $Margin/RootVBox/InfoHBox/CompanionsPanel/CompanionsLabel
@onready var facilities_label: Label = $Margin/RootVBox/InfoHBox/FacilitiesPanel/FacilitiesLabel
@onready var status_label: Label = $Margin/RootVBox/StatusLabel
@onready var expedition_button: Button = $Margin/RootVBox/ButtonsHBox/ExpeditionButton
@onready var companion_button: Button = $Margin/RootVBox/ButtonsHBox/CompanionButton
@onready var manage_button: Button = $Margin/RootVBox/ButtonsHBox/ManageButton
@onready var rest_button: Button = $Margin/RootVBox/ButtonsHBox/RestButton

func _ready() -> void:
	refresh_companions()
	refresh_facilities()
	expedition_button.pressed.connect(_on_expedition_pressed)
	companion_button.pressed.connect(_on_coming_soon_pressed.bind("동료 보기"))
	manage_button.pressed.connect(_on_coming_soon_pressed.bind("성채 관리"))
	rest_button.pressed.connect(_on_coming_soon_pressed.bind("휴식하기"))

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

func _on_expedition_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/WorldMap.tscn")

func _on_coming_soon_pressed(feature_name: String) -> void:
	status_label.text = "%s: 준비 중입니다." % feature_name
