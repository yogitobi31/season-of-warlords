extends Node

# 전역 게임 상태를 보관하는 오토로드 싱글톤입니다.
# 월드맵/전투 씬 모두 이 데이터를 공유합니다.

const PLAYER_FACTION := 0
const FACTION_NAMES := {
	0: "청람 왕국",
	1: "진홍 공국",
	2: "녹림 변경백령"
}

# 각 세력의 기본 색상입니다. (월드맵/지역 노드 표시용)
const FACTION_COLORS := {
	0: Color("3f7cff"),
	1: Color("d84a4a"),
	2: Color("4caf50")
}

const COMPANION_EXP_PER_WIN: int = 30
const COMPANION_LEVELUP_EXP: int = 100

# 지역 원본 데이터 (인접 정보 포함)
var regions: Dictionary = {}
# 현재 지역 소유권 (region_id -> faction_id)
var ownership: Dictionary = {}

# 동료 데이터 (companion_id -> Dictionary)
var companions: Dictionary = {}

# 스토리 이벤트 데이터
var story_events: Dictionary = {}
var completed_story_events: Dictionary = {}
var pending_story_event_id: String = ""
var pending_castle_event_id: String = ""
var completed_castle_events: Array[String] = []
var opening_seen: bool = false

var active_rumor_id: String = ""
var rumors: Dictionary = {}
var completed_rumors: Array[String] = []

# 기본 성채 데이터 (MVP)
var fortress_data: Dictionary = {
	"name": "청람 성채",
	"level": 1,
	"facilities": [
		{"name": "병영", "level": 1},
		{"name": "훈련장", "level": 0},
		{"name": "숙소", "level": 0}
	]
}

# 월드맵 선택 상태
var selected_region_id: String = ""
var attack_region_id: String = ""
var defense_region_id: String = ""
var last_battle_result: String = ""
var last_battle_message: String = ""

func _ready() -> void:
	initialize_regions()

func initialize_regions() -> void:
	regions = RegionData.get_regions()
	ownership.clear()
	for region_id in regions.keys():
		ownership[region_id] = regions[region_id]["owner"]
	initialize_companions()
	initialize_story_events()
	initialize_rumors()
	clear_selection()
	last_battle_result = ""
	last_battle_message = ""

func initialize_companions() -> void:
	companions = {
		"leon": {
			"id": "leon",
			"name": "레온",
			"title": "청람 기사",
			"level": 1,
			"exp": 0,
			"joined": true,
			"unlock_region_id": "",
			"battle_bonus_type": "max_hp",
			"battle_bonus_value": 15.0
		},
		"garon": {
			"id": "garon",
			"name": "가론",
			"title": "용병대장",
			"level": 1,
			"exp": 0,
			"joined": false,
			"unlock_region_id": "r2",
			"battle_bonus_type": "attack_power",
			"battle_bonus_value": 3.0
		},
		"elin": {
			"id": "elin",
			"name": "엘린",
			"title": "숲의 사수",
			"level": 1,
			"exp": 0,
			"joined": false,
			"unlock_region_id": "r3",
			"battle_bonus_type": "move_speed",
			"battle_bonus_value": 12.0
		},
		"mira": {
			"id": "mira",
			"name": "미라",
			"title": "견습 마법사",
			"level": 1,
			"exp": 0,
			"joined": false,
			"unlock_region_id": "r7",
			"battle_bonus_type": "attack_range",
			"battle_bonus_value": 8.0
		}
	}

func initialize_story_events() -> void:
	story_events = {
		"recruit_garon": {
			"id": "recruit_garon",
			"region_id": "r2",
			"title": "용병대장 가론",
			"speaker_name": "가론",
			"dialogue_lines": [
				"청람의 깃발이라… 아직도 그 깃발을 들 사람이 남아 있었나.",
				"나는 약한 군주를 따르지 않는다.",
				"하지만 백성을 버리지 않는 자라면, 내 검을 빌려줄 수는 있지."
			],
			"choices": ["함께 싸워달라.", "백성을 지키기 위해 네 힘이 필요하다."],
			"recruit_companion_id": "garon",
			"completed": false
		}
	}
	completed_story_events.clear()
	pending_story_event_id = ""


func initialize_rumors() -> void:
	rumors = {
		"rumor_garon": {
			"id": "rumor_garon",
			"title": "북부 감시요새의 용병대장",
			"target_region_id": "r2",
			"related_companion_id": "garon",
			"active": false,
			"completed": false
		},
		"rumor_elin": {
			"id": "rumor_elin",
			"title": "서리숲 관문의 숲의 사수",
			"target_region_id": "r3",
			"related_companion_id": "elin",
			"active": false,
			"completed": false
		}
	}
	completed_rumors.clear()
	active_rumor_id = ""
	pending_castle_event_id = ""
	completed_castle_events.clear()

func track_rumor(rumor_id: String) -> bool:
	if not rumors.has(rumor_id):
		return false
	if active_rumor_id != "" and rumors.has(active_rumor_id):
		var old_rumor: Dictionary = rumors[active_rumor_id]
		old_rumor["active"] = false
		rumors[active_rumor_id] = old_rumor
	var rumor_data: Dictionary = rumors[rumor_id]
	rumor_data["active"] = true
	rumor_data["completed"] = bool(rumor_data.get("completed", false))
	rumors[rumor_id] = rumor_data
	active_rumor_id = rumor_id
	return true

func get_active_rumor() -> Dictionary:
	if active_rumor_id == "":
		return {}
	return rumors.get(active_rumor_id, {})

func complete_rumor(rumor_id: String) -> void:
	if not rumors.has(rumor_id):
		return
	var rumor_data: Dictionary = rumors[rumor_id]
	rumor_data["completed"] = true
	rumor_data["active"] = false
	rumors[rumor_id] = rumor_data
	if not completed_rumors.has(rumor_id):
		completed_rumors.append(rumor_id)
	if active_rumor_id == rumor_id:
		active_rumor_id = ""

func clear_selection() -> void:
	selected_region_id = ""
	attack_region_id = ""
	defense_region_id = ""

func get_region_owner(region_id: String) -> int:
	return ownership.get(region_id, -1)

func set_region_owner(region_id: String, faction_id: int) -> void:
	if ownership.has(region_id):
		ownership[region_id] = faction_id

func get_region_name(region_id: String) -> String:
	if regions.has(region_id):
		return str(regions[region_id].get("name", region_id))
	return region_id

func get_faction_name(faction_id: int) -> String:
	return str(FACTION_NAMES.get(faction_id, "Unknown"))

func is_adjacent(from_region_id: String, to_region_id: String) -> bool:
	if not regions.has(from_region_id):
		return false
	var neighbors: Array = regions[from_region_id].get("adjacent", [])
	return to_region_id in neighbors

func set_battle_context(attacker_region_id: String, defender_region_id: String) -> void:
	attack_region_id = attacker_region_id
	defense_region_id = defender_region_id

func get_battle_title() -> String:
	if attack_region_id == "" or defense_region_id == "":
		return "전투"
	return "전투: %s → %s" % [get_region_name(attack_region_id), get_region_name(defense_region_id)]

func get_companions_list() -> Array:
	var result: Array = []
	for data in companions.values():
		result.append(data)
	result.sort_custom(func(a: Dictionary, b: Dictionary): return str(a["id"]) < str(b["id"]))
	return result

func get_joined_companions() -> Array:
	var result: Array = []
	for data in get_companions_list():
		if data.get("joined", false):
			result.append(data)
	return result

func grant_companion_exp_on_victory() -> Array[String]:
	var level_up_messages: Array[String] = []
	for companion_id in companions.keys():
		var companion: Dictionary = companions[companion_id]
		if not companion.get("joined", false):
			continue
		var current_exp: int = int(companion.get("exp", 0)) + COMPANION_EXP_PER_WIN
		var current_level: int = int(companion.get("level", 1))
		while current_exp >= COMPANION_LEVELUP_EXP:
			current_exp -= COMPANION_LEVELUP_EXP
			current_level += 1
			level_up_messages.append("%s 레벨 %d 달성!" % [companion.get("name", companion_id), current_level])
		companion["exp"] = current_exp
		companion["level"] = current_level
		companions[companion_id] = companion
	return level_up_messages

func queue_story_event_by_region(region_id: String) -> void:
	if active_rumor_id != "rumor_garon":
		return
	if region_id != "r2":
		return
	if not companions.has("garon"):
		return
	var garon_data: Dictionary = companions["garon"]
	if bool(garon_data.get("joined", false)):
		return
	if event_is_completed("recruit_garon"):
		return
	pending_story_event_id = "recruit_garon"

func event_is_completed(event_id: String) -> bool:
	if completed_story_events.get(event_id, false):
		return true
	if not story_events.has(event_id):
		return true
	var event_data: Dictionary = story_events[event_id]
	return bool(event_data.get("completed", false))

func has_pending_story_event() -> bool:
	if pending_story_event_id == "":
		return false
	return not event_is_completed(pending_story_event_id)

func get_pending_story_event() -> Dictionary:
	if not has_pending_story_event():
		return {}
	return story_events.get(pending_story_event_id, {})

func resolve_pending_story_event(_choice_index: int) -> String:
	if not has_pending_story_event():
		return ""
	var event_data: Dictionary = story_events[pending_story_event_id]
	var companion_id: String = str(event_data.get("recruit_companion_id", ""))
	var companion_name: String = companion_id
	if companions.has(companion_id):
		var companion: Dictionary = companions[companion_id]
		companion["joined"] = true
		companions[companion_id] = companion
		companion_name = str(companion.get("name", companion_id))
	event_data["completed"] = true
	story_events[pending_story_event_id] = event_data
	completed_story_events[pending_story_event_id] = true
	if pending_story_event_id == "recruit_garon":
		complete_rumor("rumor_garon")
		update_pending_castle_event()
		if active_rumor_id == "":
			track_rumor("rumor_elin")
	pending_story_event_id = ""
	return "%s이(가) 동료로 합류했습니다!" % companion_name

func apply_battle_result(player_won: bool) -> void:
	var attacked_region_name: String = get_region_name(defense_region_id)
	var retreat_region_name: String = get_region_name(attack_region_id)

	if player_won and defense_region_id != "":
		set_region_owner(defense_region_id, PLAYER_FACTION)
		last_battle_result = "player_win"
		var messages: Array[String] = ["승리! %s를 점령했습니다." % attacked_region_name]
		queue_story_event_by_region(defense_region_id)
		if has_pending_story_event():
			messages.append("새로운 동료 이벤트가 발생했습니다.")
		messages.append_array(grant_companion_exp_on_victory())
		last_battle_message = "\n".join(messages)
	else:
		last_battle_result = "player_lose"
		last_battle_message = "패배... %s로 후퇴합니다." % retreat_region_name

	clear_selection()

func has_companion_joined(companion_id: String) -> bool:
	if not companions.has(companion_id):
		return false
	var companion: Dictionary = companions[companion_id]
	return bool(companion.get("joined", false))

func get_available_rumor_ids() -> Array[String]:
	var rumor_ids: Array[String] = []
	var garon_joined: bool = has_companion_joined("garon")
	var elin_joined: bool = has_companion_joined("elin")
	if not garon_joined:
		rumor_ids.append("rumor_garon")
	elif not elin_joined:
		rumor_ids.append("rumor_elin")
	return rumor_ids

func update_pending_castle_event() -> void:
	if has_companion_joined("garon") and not completed_castle_events.has("garon_arrival"):
		pending_castle_event_id = "garon_arrival"

func has_pending_castle_event() -> bool:
	return pending_castle_event_id != ""

func complete_castle_event(event_id: String) -> void:
	if not completed_castle_events.has(event_id):
		completed_castle_events.append(event_id)
	if pending_castle_event_id == event_id:
		pending_castle_event_id = ""
