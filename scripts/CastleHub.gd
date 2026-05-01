extends Control

@onready var quest_log_label: Label = $UILayer/QuestLogPanel/QuestLogLabel
@onready var status_label: Label = $UILayer/StatusLabel
@onready var dialogue_panel: Panel = $UILayer/DialoguePanel
@onready var dialogue_speaker_label: Label = $UILayer/DialoguePanel/DialogueMargin/DialogueVBox/SpeakerNameLabel
@onready var dialogue_text_label: Label = $UILayer/DialoguePanel/DialogueMargin/DialogueVBox/DialogueTextLabel
@onready var dialogue_confirm_button: Button = $UILayer/DialoguePanel/DialogueMargin/DialogueVBox/DialogueConfirmButton

@onready var leon_marker: Panel = $SceneRoot/LeonMarker
@onready var garon_marker: Panel = $SceneRoot/GaronMarker
@onready var elin_marker: Panel = $SceneRoot/ElinMarker
@onready var mira_marker: Panel = $SceneRoot/MiraMarker
@onready var leon_button: Button = $SceneRoot/LeonMarker/LeonButton
@onready var garon_button: Button = $SceneRoot/GaronMarker/GaronButton
@onready var elin_button: Button = $SceneRoot/ElinMarker/ElinButton
@onready var mira_button: Button = $SceneRoot/MiraMarker/MiraButton
@onready var gate_button: Button = $SceneRoot/Gate/GateButton
@onready var rumor_board_button: Button = $SceneRoot/RumorBoard/RumorBoardButton
@onready var training_dummy_button: Button = $SceneRoot/TrainingDummy/TrainingDummyButton
@onready var management_button: Button = $SceneRoot/ManagementArea/ManagementButton
@onready var gate_panel: Control = $SceneRoot/Gate
@onready var rumor_board_panel: Control = $SceneRoot/RumorBoard
@onready var training_dummy_panel: Control = $SceneRoot/TrainingDummy
@onready var management_panel: Control = $SceneRoot/ManagementArea
@onready var wall_visual: ColorRect = $SceneRoot/Wall
@onready var floor_visual: ColorRect = $SceneRoot/Floor
@onready var stone_tiles_visual: ColorRect = $SceneRoot/StoneTiles

@onready var rumor_button: Button = $UILayer/TopMenu/RumorButton
@onready var companion_button: Button = $UILayer/TopMenu/CompanionButton
@onready var manage_button: Button = $UILayer/TopMenu/ManageButton

@onready var info_popup_overlay: Control = $UILayer/InfoPopupOverlay
@onready var popup_title_label: Label = $UILayer/InfoPopupOverlay/PopupPanel/PopupTitleLabel
@onready var popup_body_label: Label = $UILayer/InfoPopupOverlay/PopupPanel/PopupBodyScroll/PopupBodyLabel
@onready var popup_actions_container: HBoxContainer = $UILayer/InfoPopupOverlay/PopupPanel/PopupActionsHBox
@onready var popup_close_button: Button = $UILayer/InfoPopupOverlay/PopupPanel/PopupCloseButton
@onready var upgrade_info_panel: Panel = $UILayer/InfoPopupOverlay/PopupPanel/UpgradeInfoPanel
@onready var upgrade_info_label: Label = $UILayer/InfoPopupOverlay/PopupPanel/UpgradeInfoPanel/UpgradeInfoMargin/UpgradeInfoLabel

@onready var rumor_overlay: Control = $UILayer/RumorOverlay
@onready var rumor_title_label: Label = $UILayer/RumorOverlay/RumorPanel/RumorMargin/RumorVBox/RumorTitleLabel
@onready var rumor_body_label: Label = $UILayer/RumorOverlay/RumorPanel/RumorMargin/RumorVBox/RumorBodyLabel
@onready var rumor_track_button: Button = $UILayer/RumorOverlay/RumorPanel/RumorMargin/RumorVBox/RumorButtonsHBox/TrackRumorButton
@onready var rumor_close_button: Button = $UILayer/RumorOverlay/RumorPanel/RumorMargin/RumorVBox/RumorButtonsHBox/CloseRumorButton

@onready var castle_event_overlay: Control = $UILayer/CastleEventOverlay
@onready var castle_event_speaker_label: Label = $UILayer/CastleEventOverlay/CastleEventPanel/Margin/VBox/SpeakerLabel
@onready var castle_event_dialogue_label: Label = $UILayer/CastleEventOverlay/CastleEventPanel/Margin/VBox/DialogueLabel
@onready var castle_event_confirm_button: Button = $UILayer/CastleEventOverlay/CastleEventPanel/Margin/VBox/ConfirmButton

var hub_resource_label: Label
var hub_hint_label: Label
var contextual_menu_panel: Panel
var contextual_menu_title: Label
var contextual_primary_button: Button
var contextual_close_button: Button
var selected_target_id: String = ""
const DEFAULT_COURTYARD_TEXT: String = "청람 성채 안뜰이다. 소문 게시판을 확인하거나 성문을 통해 출정할 수 있다."
const CASTLE_HUB_PIXEL_ASSET_ROOT: String = "res://assets/pixel/castlehub/"
const CASTLE_HUB_REQUIRED_TEXTURE_PATHS: Array[String] = [
	"res://assets/pixel/castlehub/characters/leon_idle.png",
	"res://assets/pixel/castlehub/characters/garon_idle.png",
	"res://assets/pixel/castlehub/characters/elin_idle.png",
	"res://assets/pixel/castlehub/characters/mira_idle.png",
	"res://assets/pixel/castlehub/objects/rumor_board.png",
	"res://assets/pixel/castlehub/objects/training_dummy.png",
	"res://assets/pixel/castlehub/objects/castle_gate.png",
	"res://assets/pixel/castlehub/objects/management_desk.png",
	"res://assets/pixel/castlehub/tiles/courtyard_ground_tile.png",
	"res://assets/pixel/castlehub/tiles/castle_wall_tile.png"
]

var rumor_panel_rumor_id: String = ""
var opening_lines: Array[String] = []
var opening_index: int = 0
var opening_active: bool = false
var upgrade_barracks_button: Button
var upgrade_training_button: Button
var upgrade_lodging_button: Button
var current_popup_mode: String = ""
var hovered_upgrade_key: String = ""

func _ready() -> void:
	apply_castlehub_pixel_art_if_available()
	configure_interaction_layers()
	log_missing_castlehub_textures()
	build_character_markers()
	refresh_quest_log()
	refresh_rumor_panel()
	refresh_courtyard_people()
	GameState.update_pending_castle_event()
	refresh_castle_event_panel()
	build_hub_layout()
	configure_scene_layout()
	refresh_status_message()
	refresh_hub_header()
	select_hub_target("")

	gate_button.pressed.connect(_on_gate_selected)
	rumor_board_button.pressed.connect(_on_rumor_board_selected)
	training_dummy_button.pressed.connect(_on_training_dummy_pressed)
	leon_button.pressed.connect(_on_leon_pressed)
	garon_button.pressed.connect(_on_garon_pressed)
	elin_button.pressed.connect(_on_elin_pressed)
	mira_button.pressed.connect(_on_mira_pressed)
	management_button.pressed.connect(_on_management_selected)
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
	upgrade_barracks_button.custom_minimum_size = Vector2(160, 38)
	upgrade_barracks_button.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	upgrade_barracks_button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	upgrade_barracks_button.pressed.connect(_on_upgrade_barracks_pressed)
	upgrade_barracks_button.mouse_entered.connect(_on_upgrade_barracks_mouse_entered)
	upgrade_barracks_button.mouse_exited.connect(_on_upgrade_button_mouse_exited)
	popup_actions_container.add_child(upgrade_barracks_button)

	upgrade_training_button = Button.new()
	upgrade_training_button.text = "훈련장 강화"
	upgrade_training_button.custom_minimum_size = Vector2(160, 38)
	upgrade_training_button.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	upgrade_training_button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	upgrade_training_button.pressed.connect(_on_upgrade_training_pressed)
	upgrade_training_button.mouse_entered.connect(_on_upgrade_training_mouse_entered)
	upgrade_training_button.mouse_exited.connect(_on_upgrade_button_mouse_exited)
	popup_actions_container.add_child(upgrade_training_button)

	upgrade_lodging_button = Button.new()
	upgrade_lodging_button.text = "숙소 강화"
	upgrade_lodging_button.custom_minimum_size = Vector2(160, 38)
	upgrade_lodging_button.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	upgrade_lodging_button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	upgrade_lodging_button.pressed.connect(_on_upgrade_lodging_pressed)
	upgrade_lodging_button.mouse_entered.connect(_on_upgrade_lodging_mouse_entered)
	upgrade_lodging_button.mouse_exited.connect(_on_upgrade_button_mouse_exited)
	popup_actions_container.add_child(upgrade_lodging_button)
	hide_upgrade_info()
	refresh_upgrade_button_tooltips()

func create_character_sprite(character_name: String, character_title: String, body_color: Color) -> Control:
	var pixel_art_path: String = CASTLE_HUB_PIXEL_ASSET_ROOT + "characters/%s_idle.png" % character_name_to_asset_id(character_name)
	var pixel_art: Texture2D = try_load_texture(pixel_art_path)
	if pixel_art:
		var sprite_root: Control = Control.new()
		sprite_root.custom_minimum_size = Vector2(130, 130)

		var texture_rect: TextureRect = TextureRect.new()
		texture_rect.texture = pixel_art
		texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		texture_rect.anchor_right = 1.0
		texture_rect.anchor_bottom = 1.0
		texture_rect.offset_bottom = -30.0
		texture_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		sprite_root.add_child(texture_rect)

		var name_label: Label = Label.new()
		name_label.text = character_name
		name_label.position = Vector2(0, 82)
		name_label.size = Vector2(130, 22)
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		sprite_root.add_child(name_label)
		return sprite_root

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

func character_name_to_asset_id(character_name: String) -> String:
	match character_name:
		"레온":
			return "leon"
		"가론":
			return "garon"
		"엘린":
			return "elin"
		"미라":
			return "mira"
		_:
			return ""

func try_load_texture(path: String) -> Texture2D:
	if not ResourceLoader.exists(path):
		return null
	var loaded: Resource = load(path)
	return loaded as Texture2D

func add_pixel_texture_to_control(target: Control, texture_path: String) -> bool:
	var texture: Texture2D = try_load_texture(texture_path)
	if not texture:
		return false

	var texture_rect: TextureRect = TextureRect.new()
	texture_rect.name = "PixelArtVisual"
	texture_rect.texture = texture
	texture_rect.anchor_right = 1.0
	texture_rect.anchor_bottom = 1.0
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	texture_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	target.add_child(texture_rect)
	target.move_child(texture_rect, 0)
	return true

func apply_castlehub_pixel_art_if_available() -> void:
	add_pixel_texture_to_control(gate_panel, CASTLE_HUB_PIXEL_ASSET_ROOT + "objects/castle_gate.png")
	add_pixel_texture_to_control(rumor_board_panel, CASTLE_HUB_PIXEL_ASSET_ROOT + "objects/rumor_board.png")
	add_pixel_texture_to_control(training_dummy_panel, CASTLE_HUB_PIXEL_ASSET_ROOT + "objects/training_dummy.png")
	add_pixel_texture_to_control(management_panel, CASTLE_HUB_PIXEL_ASSET_ROOT + "objects/management_desk.png")

func apply_tile_texture_if_available(target: ColorRect, texture_path: String) -> bool:
	if target == null:
		return false
	var texture: Texture2D = try_load_texture(texture_path)
	if not texture:
		return false
	var tile_overlay: TextureRect = TextureRect.new()
	tile_overlay.name = "PixelTileVisual"
	tile_overlay.texture = texture
	tile_overlay.anchor_right = 1.0
	tile_overlay.anchor_bottom = 1.0
	tile_overlay.stretch_mode = TextureRect.STRETCH_TILE
	tile_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	target.add_child(tile_overlay)
	target.move_child(tile_overlay, 0)
	return true

func configure_interaction_layers() -> void:
	apply_tile_texture_if_available(floor_visual, CASTLE_HUB_PIXEL_ASSET_ROOT + "tiles/courtyard_ground_tile.png")
	apply_tile_texture_if_available(wall_visual, CASTLE_HUB_PIXEL_ASSET_ROOT + "tiles/castle_wall_tile.png")
	apply_tile_texture_if_available(stone_tiles_visual, CASTLE_HUB_PIXEL_ASSET_ROOT + "tiles/courtyard_ground_tile.png")

	for decorative_path: NodePath in [
		NodePath("SceneRoot/Gate/GateLabel"),
		NodePath("SceneRoot/RumorBoard/RumorBoardLabel"),
		NodePath("SceneRoot/TrainingDummy/TrainingDummyLabel"),
		NodePath("SceneRoot/ManagementArea/ManagementLabel"),
		NodePath("SceneRoot/Keep/KeepLabel")
	]:
		var decorative_control: Control = get_node_or_null(decorative_path) as Control
		if decorative_control:
			decorative_control.mouse_filter = Control.MOUSE_FILTER_IGNORE

	for hotspot: Button in [leon_button, garon_button, elin_button, mira_button, gate_button, rumor_board_button, training_dummy_button, management_button]:
		hotspot.mouse_filter = Control.MOUSE_FILTER_STOP


func log_missing_castlehub_textures() -> void:
	for texture_path: String in CASTLE_HUB_REQUIRED_TEXTURE_PATHS:
		if not ResourceLoader.exists(texture_path):
			push_warning("CastleHub texture missing, fallback visuals in use: %s" % texture_path)

func build_character_markers() -> void:
	for child: Node in leon_marker.get_children():
		if child != leon_button:
			child.queue_free()
	for child: Node in garon_marker.get_children():
		if child != garon_button:
			child.queue_free()
	for child: Node in elin_marker.get_children():
		if child != elin_button:
			child.queue_free()
	for child: Node in mira_marker.get_children():
		if child != mira_button:
			child.queue_free()
	leon_marker.add_child(create_character_sprite("레온", "청람 기사", Color(0.2, 0.38, 0.8, 1)))
	garon_marker.add_child(create_character_sprite("가론", "용병대장", Color(0.46, 0.28, 0.2, 1)))
	elin_marker.add_child(create_character_sprite("엘린", "숲의 사수", Color(0.2, 0.55, 0.3, 1)))
	mira_marker.add_child(create_character_sprite("미라", "견습 마법사", Color(0.45, 0.3, 0.8, 1)))
	leon_marker.move_child(leon_button, leon_marker.get_child_count() - 1)
	garon_marker.move_child(garon_button, garon_marker.get_child_count() - 1)
	elin_marker.move_child(elin_button, elin_marker.get_child_count() - 1)
	mira_marker.move_child(mira_button, mira_marker.get_child_count() - 1)

func _on_gate_selected() -> void:
	if opening_active:
		return
	select_hub_target("gate")

func _on_rumor_board_selected() -> void:
	if opening_active:
		return
	select_hub_target("rumor")

func _on_expedition_pressed() -> void:
	if opening_active:
		return
	get_tree().change_scene_to_file("res://scenes/WorldMap.tscn")

func _on_rumor_pressed() -> void:
	if opening_active:
		return
	refresh_rumor_panel()
	rumor_overlay.visible = true
	hide_contextual_menu()

func _on_leon_pressed() -> void:
	if opening_active:
		return
	select_hub_target("leon")

func _on_garon_pressed() -> void:
	if opening_active:
		return
	if not GameState.has_companion_joined("garon"):
		return
	select_hub_target("garon")

func _on_elin_pressed() -> void:
	if opening_active:
		return
	if not GameState.has_companion_joined("elin"):
		return
	select_hub_target("elin")


func _on_mira_pressed() -> void:
	if opening_active:
		return
	if not GameState.has_companion_joined("mira"):
		return
	select_hub_target("mira")

func _on_dialogue_confirm_pressed() -> void:
	if opening_active:
		advance_opening()
		return
	dialogue_panel.visible = false

func _on_companion_popup_pressed() -> void:
	if opening_active:
		return
	show_popup("동료 보기", build_companion_text(), "companion")

func _on_manage_popup_pressed() -> void:
	if opening_active:
		return
	show_popup("성채 관리", build_manage_text(), "manage")

func show_popup(title: String, body: String, mode: String = "generic") -> void:
	current_popup_mode = mode
	popup_title_label.text = title
	popup_body_label.text = body
	var is_manage_mode: bool = (mode == "manage")
	upgrade_barracks_button.visible = is_manage_mode
	upgrade_training_button.visible = is_manage_mode
	upgrade_lodging_button.visible = is_manage_mode
	upgrade_info_panel.visible = is_manage_mode
	if is_manage_mode:
		hide_upgrade_info()
		refresh_upgrade_button_tooltips()
	info_popup_overlay.visible = true

func _on_close_info_popup_pressed() -> void:
	info_popup_overlay.visible = false
	current_popup_mode = ""

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
	var lines: Array[String] = []
	lines.append("현재 자원")
	lines.append("- 금화: %d" % GameState.gold)
	lines.append("- 보급: %d" % GameState.supplies)
	lines.append("- 자재: %d" % GameState.materials)
	lines.append("- 명성: %d" % GameState.renown)
	lines.append("")
	lines.append("시설 현황")
	lines.append("- 병영 Lv.%d" % GameState.barracks_level)
	lines.append("- 훈련장 Lv.%d" % GameState.training_ground_level)
	lines.append("- 숙소 Lv.%d" % GameState.lodging_level)
	lines.append("")
	lines.append("추천")
	lines.append("- 부족한 자원은 주변 소규모 지역에서 확보하세요.")
	lines.append("- 강화 전, 아래 버튼에 마우스를 올려 비용과 효과를 확인하세요.")
	return "\n".join(lines)

func refresh_upgrade_button_tooltips() -> void:
	# 강화 상세 정보는 UpgradeInfoPanel 단일 시스템에서만 표시합니다.
	upgrade_barracks_button.tooltip_text = ""
	upgrade_training_button.tooltip_text = ""
	upgrade_lodging_button.tooltip_text = ""

func show_upgrade_info(upgrade_key: String) -> void:
	hovered_upgrade_key = upgrade_key
	var cost: Dictionary = GameState.get_upgrade_cost(upgrade_key)
	var need_gold: int = int(cost.get("gold", 0))
	var need_materials: int = int(cost.get("materials", 0))
	var enough_resources: bool = GameState.gold >= need_gold and GameState.materials >= need_materials
	upgrade_info_label.text = "%s\n비용: 금화 %d / 자재 %d\n효과: %s\n현재 보너스: %s → 강화 후: %s\n보유 자원: 금화 %d / 자재 %d / 상태: %s" % [get_upgrade_display_name(upgrade_key), need_gold, need_materials, get_upgrade_effect_text(upgrade_key), get_upgrade_current_bonus_text(upgrade_key), get_upgrade_next_bonus_text(upgrade_key), GameState.gold, GameState.materials, "강화 가능" if enough_resources else "자원 부족"]

func hide_upgrade_info() -> void:
	hovered_upgrade_key = ""
	upgrade_info_label.text = "강화 버튼에 마우스를 올리면 비용과 효과가 표시됩니다."

func get_upgrade_display_name(upgrade_key: String) -> String:
	match upgrade_key:
		"barracks":
			return "병영 강화"
		"training_ground":
			return "훈련장 강화"
		"lodging":
			return "숙소 강화"
		_:
			return "시설 강화"

func get_upgrade_effect_text(upgrade_key: String) -> String:
	match upgrade_key:
		"barracks":
			return "일반 병사의 최대 HP 증가"
		"training_ground":
			return "일반 병사의 공격력 증가"
		"lodging":
			return "부대 사기 보너스 증가"
		_:
			return "전력 보너스"

func get_upgrade_current_bonus_text(upgrade_key: String) -> String:
	match upgrade_key:
		"barracks":
			return "+%.1f" % GameState.get_soldier_hp_bonus()
		"training_ground":
			return "+%.1f" % GameState.get_soldier_attack_bonus()
		"lodging":
			return "+%.1f" % GameState.get_army_morale_bonus()
		_:
			return "+0.0"

func get_upgrade_next_bonus_text(upgrade_key: String) -> String:
	match upgrade_key:
		"barracks":
			return "+%.1f" % (float(GameState.barracks_level) * 18.0)
		"training_ground":
			return "+%.1f" % (float(GameState.training_ground_level + 1) * 1.6)
		"lodging":
			return "+%.1f" % (float(GameState.lodging_level + 1) * 0.8)
		_:
			return "+0.0"

func get_upgrade_level(upgrade_key: String) -> int:
	match upgrade_key:
		"barracks":
			return GameState.barracks_level
		"training_ground":
			return GameState.training_ground_level
		"lodging":
			return GameState.lodging_level
		_:
			return 0

func _on_upgrade_barracks_pressed() -> void:
	_try_upgrade("barracks")

func _on_upgrade_training_pressed() -> void:
	_try_upgrade("training_ground")

func _on_upgrade_lodging_pressed() -> void:
	_try_upgrade("lodging")

func _try_upgrade(upgrade_key: String) -> void:
	var success: bool = GameState.try_upgrade_castle(upgrade_key)
	if success:
		show_popup("성채 관리 - 강화 성공", build_manage_text(), "manage")
	else:
		show_popup("성채 관리 - 자원 부족", build_manage_text(), "manage")
	refresh_upgrade_button_tooltips()
	if current_popup_mode == "manage":
		if hovered_upgrade_key == upgrade_key:
			show_upgrade_info(upgrade_key)
		else:
			hide_upgrade_info()

func _on_upgrade_barracks_mouse_entered() -> void:
	show_upgrade_info("barracks")

func _on_upgrade_training_mouse_entered() -> void:
	show_upgrade_info("training_ground")

func _on_upgrade_lodging_mouse_entered() -> void:
	show_upgrade_info("lodging")

func _on_upgrade_button_mouse_exited() -> void:
	hide_upgrade_info()

func build_castle_people_text() -> String:
	var lines: Array[String] = ["성채 인물"]
	for companion_data: Dictionary in GameState.get_joined_companions():
		lines.append("- %s" % str(companion_data.get("name", "?")))
	return "\n".join(lines)


func build_hub_layout() -> void:
	hub_resource_label = Label.new()
	hub_resource_label.position = Vector2(20, 10)
	hub_resource_label.size = Vector2(980, 26)
	hub_resource_label.add_theme_font_size_override("font_size", 18)
	$UILayer.add_child(hub_resource_label)

	hub_hint_label = Label.new()
	hub_hint_label.position = Vector2(20, 34)
	hub_hint_label.size = Vector2(620, 20)
	hub_hint_label.add_theme_font_size_override("font_size", 14)
	$UILayer.add_child(hub_hint_label)

	contextual_menu_panel = Panel.new()
	contextual_menu_panel.position = Vector2(930, 480)
	contextual_menu_panel.size = Vector2(260, 130)
	contextual_menu_panel.visible = false
	$UILayer.add_child(contextual_menu_panel)

	contextual_menu_title = Label.new()
	contextual_menu_title.position = Vector2(14, 10)
	contextual_menu_title.size = Vector2(230, 24)
	contextual_menu_panel.add_child(contextual_menu_title)

	contextual_primary_button = Button.new()
	contextual_primary_button.position = Vector2(14, 40)
	contextual_primary_button.size = Vector2(230, 34)
	contextual_primary_button.pressed.connect(_on_contextual_primary_pressed)
	contextual_menu_panel.add_child(contextual_primary_button)

	contextual_close_button = Button.new()
	contextual_close_button.position = Vector2(14, 82)
	contextual_close_button.size = Vector2(230, 30)
	contextual_close_button.text = "닫기"
	contextual_close_button.pressed.connect(_on_contextual_close_pressed)
	contextual_menu_panel.add_child(contextual_close_button)

func configure_scene_layout() -> void:
	$UILayer/QuestLogPanel.visible = false
	status_label.visible = false
	$UILayer/TopMenu.visible = false
	dialogue_panel.visible = true
	dialogue_panel.offset_left = 0
	dialogue_panel.offset_right = 1280
	dialogue_panel.offset_top = 520
	dialogue_panel.offset_bottom = 720
	dialogue_panel.self_modulate = Color(0.05, 0.07, 0.11, 0.86)
	dialogue_speaker_label.visible = false
	dialogue_confirm_button.visible = false
	dialogue_text_label.custom_minimum_size = Vector2(0, 120)
	dialogue_text_label.add_theme_font_size_override("font_size", 24)
	dialogue_text_label.modulate = Color(0.95, 0.97, 1.0, 1.0)

func refresh_hub_header() -> void:
	if hub_resource_label == null:
		return
	if hub_hint_label == null:
		return
	hub_resource_label.text = "금화 %d   보급 %d   자재 %d   명성 %d" % [GameState.gold, GameState.supplies, GameState.materials, GameState.renown]
	hub_hint_label.text = "목표: %s" % GameState.get_current_objective_text()

func select_hub_target(target_id: String) -> void:
	selected_target_id = target_id
	if target_id == "":
		dialogue_text_label.text = DEFAULT_COURTYARD_TEXT
		hide_contextual_menu()
		return
	var command_label: String = "대화하기"
	var title: String = "행동"
	match target_id:
		"leon":
			dialogue_text_label.text = "레온: 지금은 작은 성채에 불과하지만, 동료가 모이면 달라질 겁니다."
			title = "레온"
		"gate":
			dialogue_text_label.text = "성문 밖으로 나가 출정할 지역을 선택합니다."
			command_label = "출정하기"
			title = "성문"
		"rumor":
			dialogue_text_label.text = "새로운 소문과 사건을 확인할 수 있습니다."
			command_label = "소문 확인"
			title = "소문 게시판"
		"training":
			dialogue_text_label.text = "병사들의 기초 훈련을 진행할 수 있습니다."
			command_label = "훈련장"
			title = "훈련 목각"
		"management":
			dialogue_text_label.text = "성채 시설을 정비하고 강화할 수 있습니다."
			command_label = "성채 관리"
			title = "관리 구역"
		"garon":
			dialogue_text_label.text = "가론: 성문 주변은 내가 맡겠다. 다음 출정 준비는 끝났다."
			title = "가론"
		"elin":
			dialogue_text_label.text = "엘린: 바람이 바뀌면 적의 움직임도 보여요. 제가 길을 찾겠습니다."
			title = "엘린"
		"mira":
			dialogue_text_label.text = "미라: 아직 서툴지만, 이 성채를 지키는 마법을 배우고 싶어요."
			title = "미라"
	show_contextual_menu(title, command_label)

func show_contextual_menu(title: String, action_text: String) -> void:
	contextual_menu_title.text = title
	contextual_primary_button.text = action_text
	contextual_menu_panel.visible = true

func hide_contextual_menu() -> void:
	contextual_menu_panel.visible = false

func _on_contextual_close_pressed() -> void:
	select_hub_target("")

func _on_contextual_primary_pressed() -> void:
	match selected_target_id:
		"gate":
			_on_expedition_pressed()
		"rumor":
			_on_rumor_pressed()
		"training":
			show_popup("훈련 목각", build_training_dummy_text(), "training")
		"management":
			_on_manage_popup_pressed()
		_:
			pass

func refresh_quest_log() -> void:
	if not GameState.has_companion_joined("garon"):
		quest_log_label.text = "현재 목표:\n북부 감시요새의 가론을 찾아라"
	elif not GameState.has_companion_joined("elin"):
		quest_log_label.text = "현재 목표:\n서리숲 관문의 숲의 사수를 찾아라"
	elif not GameState.has_companion_joined("mira"):
		quest_log_label.text = "현재 목표:\n고대 유적지의 견습 마법사를 찾아라"
	else:
		quest_log_label.text = "현재 목표:\n성채를 정비하고 다음 원정을 준비하라"

func refresh_status_message() -> void:
	refresh_hub_header()

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
	elif rumor_panel_rumor_id == "rumor_elin":
		body_text = "\"서리숲 관문 근처에서 진홍 공국의 정찰대를 홀로 막아내는 사수가 있다는 소문이 있습니다.\"\n"
		body_text += "\"그녀는 숲을 지키기 위해 누구의 깃발도 따르지 않는다고 합니다.\"\n\n관련 동료: 엘린"
	elif rumor_panel_rumor_id == "rumor_mira":
		body_text = "\"엘린은 청람의 고대 유적지 아래에서 이상한 마력의 흐름을 감지했다고 보고했다.\"\n"
		body_text += "\"그 땅은 이미 우리의 영지지만, 유적의 침묵 속에는 아직 밝혀지지 않은 무언가가 남아 있다.\"\n\n대상 지역: 고대 유적지\n원정 방식: 조사(Exploration)"
	else:
		body_text = "\"새로운 소문이 없습니다.\""
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

func _on_training_dummy_pressed() -> void:
	if opening_active:
		return
	select_hub_target("training")

func _on_management_selected() -> void:
	if opening_active:
		return
	select_hub_target("management")

func build_training_dummy_text() -> String:
	var lines: Array[String] = []
	lines.append("병사들이 기본 전투 자세를 연습하는 훈련용 목각입니다.")
	lines.append("현재 해금된 병종을 확인하고, 다음 전투를 준비할 수 있습니다.")
	lines.append("")
	lines.append("해금 병종:")
	for class_id: String in GameState.unlocked_unit_classes:
		var class_data: Dictionary = GameState.UNIT_CLASSES.get(class_id, {})
		lines.append("- %s" % str(class_data.get("display_name", class_id)))
	lines.append("")
	lines.append("상성 팁:")
	lines.append("- 창병은 기병에게 강합니다.")
	lines.append("- 방패보병은 전열 유지에 강하지만 마법에 약합니다.")
	lines.append("- 기병은 궁수와 소서러에게 강하지만 창병에게 약합니다.")
	lines.append("")
	lines.append("현재 성채 전투 보너스:")
	lines.append("- 병영 보너스(체력): +%.1f" % GameState.get_soldier_hp_bonus())
	lines.append("- 훈련장 보너스(공격력): +%.1f" % GameState.get_soldier_attack_bonus())
	lines.append("- 숙소 보너스(사기): +%.1f" % GameState.get_army_morale_bonus())
	return "\n".join(lines)

func refresh_courtyard_people() -> void:
	garon_marker.visible = GameState.has_companion_joined("garon")
	elin_marker.visible = GameState.has_companion_joined("elin")
	mira_marker.visible = GameState.has_companion_joined("mira")

func refresh_castle_event_panel() -> void:
	if GameState.pending_castle_event_id == "garon_arrival":
		castle_event_speaker_label.text = "레온 / 가론"
		castle_event_dialogue_label.text = "레온:\n\"주군, 북부 감시요새에서 데려온 용병대장이 도착했습니다.\"\n\n가론:\n\"여기가 청람 성채인가.\"\n\"생각보다 낡았군. 병사들도 지쳐 있고.\"\n\n레온:\n\"말은 조심하는 게 좋을 거다.\"\n\n가론:\n\"하지만 깃발은 아직 내려가지 않았군.\"\n\"좋다. 적어도 이곳에는 아직 싸울 이유가 남아 있어.\"\n\n레온:\n\"주군, 가론이 합류한 것은 큰 힘이 될 겁니다.\"\n\n가론이 청람 성채에 합류했습니다."
		castle_event_overlay.visible = true
		return
	if GameState.pending_castle_event_id == "elin_arrival":
		castle_event_speaker_label.text = "레온 / 엘린"
		castle_event_dialogue_label.text = "레온:\n\"주군, 서리숲 관문에서 온 사수가 도착했습니다.\"\n\n엘린:\n\"여기가 청람 성채구나.\"\n\"낡았네. 하지만… 난민들이 말한 것처럼, 아직 불빛은 남아 있어.\"\n\n레온:\n\"말은 조심하는 게 좋을 거다.\"\n\n엘린:\n\"걱정 마. 난 거짓 깃발에는 활을 겨누지만, 지키려는 사람에게는 등을 맡겨.\"\n\n레온:\n\"주군, 엘린이 합류한 것은 큰 힘이 될 겁니다.\"\n\n엘린이 청람 성채에 합류했습니다."
		castle_event_overlay.visible = true
		return
	if GameState.pending_castle_event_id == "mira_arrival":
		castle_event_speaker_label.text = "레온 / 미라"
		castle_event_dialogue_label.text = "레온:\n\"주군, 고대 유적지에서 데려온 견습 마법사가 도착했습니다.\"\n\n미라:\n\"여기가 청람 성채군요.\"\n\"생각보다… 낡았지만, 이상하게 따뜻해요.\"\n\n가론:\n\"마법사는 처음부터 믿기 어렵군.\"\n\n엘린:\n\"하지만 저 아이의 손은 떨리고 있어. 병기가 되고 싶은 사람의 눈은 아니야.\"\n\n미라:\n\"저는 강해지고 싶어요. 하지만 누군가를 지키기 위해 강해지고 싶어요.\"\n\n레온:\n\"주군, 미라가 합류했습니다. 이제 청람 성채도 마법의 힘을 다룰 수 있게 될 겁니다.\"\n\n미라가 청람 성채에 합류했습니다."
		castle_event_overlay.visible = true
		return
	castle_event_overlay.visible = false

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if not info_popup_overlay.visible and not rumor_overlay.visible and not castle_event_overlay.visible and not opening_active:
			select_hub_target("")
	if event.is_action_pressed("ui_cancel") and info_popup_overlay.visible and not opening_active:
		_on_close_info_popup_pressed()
		get_viewport().set_input_as_handled()

func _on_castle_event_confirm_pressed() -> void:
	if opening_active:
		return
	if GameState.pending_castle_event_id == "garon_arrival":
		GameState.complete_castle_event("garon_arrival")
	elif GameState.pending_castle_event_id == "elin_arrival":
		GameState.complete_castle_event("elin_arrival")
	elif GameState.pending_castle_event_id == "mira_arrival":
		GameState.complete_castle_event("mira_arrival")
	refresh_castle_event_panel()
	refresh_rumor_panel()
	refresh_quest_log()
	refresh_courtyard_people()
	refresh_hub_header()

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
