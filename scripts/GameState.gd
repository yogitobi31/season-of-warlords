extends Node

# 전역 게임 상태를 보관하는 오토로드 싱글톤입니다.
# 월드맵/전투 씬 모두 이 데이터를 공유합니다.

const PLAYER_FACTION: int = 0
const CRIMSON_DUCHY_FACTION: int = 1
const GREEN_MARQUIS_FACTION: int = 2
const FACTION_NAMES := {
	PLAYER_FACTION: "청람 왕국",
	CRIMSON_DUCHY_FACTION: "진홍 공국",
	GREEN_MARQUIS_FACTION: "녹림 변경백령"
}

# 각 세력의 기본 색상입니다. (월드맵/지역 노드 표시용)
const FACTION_COLORS := {
	PLAYER_FACTION: Color("3f7cff"),
	CRIMSON_DUCHY_FACTION: Color("d84a4a"),
	GREEN_MARQUIS_FACTION: Color("4caf50")
}

const COMPANION_EXP_PER_WIN: int = 30
const COMPANION_LEVELUP_EXP: int = 100
const DEFAULT_BATTLE_REWARD: Dictionary = {"gold": 60, "supplies": 15, "materials": 15, "renown": 3, "companion_exp": 30}
const RESOURCE_DEFINITIONS: Dictionary = {
	"gold": {"display_name": "금화", "description": "병사 고용, 훈련, 장비 구입에 쓰이는 범용 화폐입니다."},
	"supplies": {"display_name": "보급", "description": "출정 유지, 회복, 병참과 숙소 운영에 필요한 물자입니다."},
	"materials": {"display_name": "자재", "description": "성채 강화, 대장간, 장비 제작에 필요한 건축/제작 재료입니다."},
	"renown": {"display_name": "명성", "description": "청람 성채에 대한 신뢰와 평판입니다. 동료, 소문, 직업 해금 조건으로 사용됩니다."}
}

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
var gold: int = 120
var supplies: int = 80
var materials: int = 60
var renown: int = 0
var barracks_level: int = 1
var training_ground_level: int = 0
var lodging_level: int = 0
var unlocked_unit_classes: Array[String] = ["infantry"]

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

const UNIT_CLASSES: Dictionary = {
	"infantry": {"display_name": "보병", "max_hp": 100.0, "attack": 12.0, "move_speed": 80.0, "attack_range": 26.0, "role": "균형형 전열", "strengths": "특화 없음", "weaknesses": "전문화된 상성 대응 부족"},
	"spearman": {"display_name": "창병", "max_hp": 92.0, "attack": 12.5, "move_speed": 82.0, "attack_range": 28.0, "role": "대기병 대응", "strengths": "기병에게 강함", "weaknesses": "방패보병 상대로 장기전 약세"},
	"shieldbearer": {"display_name": "방패보병", "max_hp": 128.0, "attack": 9.5, "move_speed": 68.0, "attack_range": 24.0, "role": "탱커", "strengths": "궁수 피해 감소", "weaknesses": "마법에 취약"},
	"cavalry": {"display_name": "기병", "max_hp": 104.0, "attack": 13.5, "move_speed": 112.0, "attack_range": 24.0, "role": "돌격", "strengths": "궁수/소서러 견제", "weaknesses": "창병에게 취약"},
	"archer": {"display_name": "궁수", "max_hp": 78.0, "attack": 11.5, "move_speed": 78.0, "attack_range": 120.0, "role": "원거리 화력", "strengths": "안전한 견제", "weaknesses": "기병에게 취약"},
	"cleric": {"display_name": "성직자", "max_hp": 86.0, "attack": 7.0, "move_speed": 76.0, "attack_range": 72.0, "role": "지원", "strengths": "사기/회복 지원", "weaknesses": "화력 부족"},
	"sorcerer": {"display_name": "소서러", "max_hp": 74.0, "attack": 15.0, "move_speed": 74.0, "attack_range": 96.0, "role": "마법 화력", "strengths": "방패보병/밀집대형 대응", "weaknesses": "기병에게 취약"}
}

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
	gold = 120
	supplies = 80
	materials = 60
	renown = 0
	barracks_level = 1
	training_ground_level = 0
	lodging_level = 0
	unlocked_unit_classes = ["infantry"]

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
		},
		"recruit_elin": {
			"id": "recruit_elin",
			"region_id": "r3",
			"title": "숲의 사수 엘린",
			"speaker_name": "엘린",
			"dialogue_lines": [
				"멈춰. 이 숲은 진홍 공국의 길도, 청람 왕국의 길도 아니야.",
				"나는 깃발을 믿지 않아. 숲을 버리고 도망친 군주들을 너무 많이 봤거든.",
				"하지만… 난민 야영지의 아이들이 네 이름을 말하더라.",
				"네가 정말 사람을 버리지 않는 자라면, 내 활은 네 길을 막지 않을 거야."
			],
			"choices": ["우리는 숲과 사람을 함께 지킬 것이다.", "청람의 깃발은 버려진 이들을 위해 다시 선다."],
			"recruit_companion_id": "elin",
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
		},
		"rumor_mira": {
			"id": "rumor_mira",
			"title": "고대 유적지의 견습 마법사",
			"target_region_id": "r7",
			"related_companion_id": "mira",
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


func is_unit_class_unlocked(class_id: String) -> bool:
	return unlocked_unit_classes.has(class_id)

func unlock_unit_class(class_id: String) -> bool:
	if not UNIT_CLASSES.has(class_id):
		return false
	if unlocked_unit_classes.has(class_id):
		return false
	unlocked_unit_classes.append(class_id)
	return true

func get_player_composition() -> Array[String]:
	var composition: Array[String] = []
	for i: int in range(6):
		composition.append("infantry")
	if is_unit_class_unlocked("spearman"):
		composition.append("spearman")
		composition.append("spearman")
	if is_unit_class_unlocked("shieldbearer"):
		composition.append("shieldbearer")
		composition.append("shieldbearer")
	while composition.size() < 10:
		composition.append("infantry")
	if composition.size() > 10:
		var trimmed: Array[String] = []
		for i: int in range(10):
			trimmed.append(composition[i])
		composition = trimmed
	return composition

func get_region_enemy_classes(region_id: String) -> Array[String]:
	var fallback: Array[String] = ["infantry"]
	if not regions.has(region_id):
		return fallback
	var region_data: Dictionary = regions[region_id]
	if region_data.has("expected_enemy_classes"):
		var classes: Array[String] = []
		for class_variant: Variant in region_data.get("expected_enemy_classes", []):
			classes.append(str(class_variant))
		if not classes.is_empty():
			return classes
	var encounter_type: String = str(region_data.get("encounter_type", ""))
	match encounter_type:
		"bandit":
			return ["infantry", "infantry"]
		"beast":
			return ["cavalry", "infantry"]
		"crimson_scout":
			return ["infantry", "archer"]
		"fortress":
			return ["infantry", "shieldbearer", "archer"]
		_:
			return fallback

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

func grant_companion_exp_on_victory(exp_gain: int = COMPANION_EXP_PER_WIN) -> Array[String]:
	var level_up_messages: Array[String] = []
	for companion_id in companions.keys():
		var companion: Dictionary = companions[companion_id]
		if not companion.get("joined", false):
			continue
		var current_exp: int = int(companion.get("exp", 0)) + exp_gain
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
	if active_rumor_id == "":
		return
	var rumor_to_event: Dictionary = {
		"rumor_garon": {"region_id": "r2", "event_id": "recruit_garon", "companion_id": "garon"},
		"rumor_elin": {"region_id": "r3", "event_id": "recruit_elin", "companion_id": "elin"}
	}
	if not rumor_to_event.has(active_rumor_id):
		return
	var mapping: Dictionary = rumor_to_event[active_rumor_id]
	var target_region_id: String = str(mapping.get("region_id", ""))
	var event_id: String = str(mapping.get("event_id", ""))
	var companion_id: String = str(mapping.get("companion_id", ""))
	if region_id != target_region_id:
		return
	if not companions.has(companion_id):
		return
	var companion_data: Dictionary = companions[companion_id]
	if bool(companion_data.get("joined", false)):
		return
	if event_is_completed(event_id):
		return
	pending_story_event_id = event_id

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
	var resolved_event_id: String = pending_story_event_id
	if resolved_event_id == "recruit_garon":
		complete_rumor("rumor_garon")
		pending_castle_event_id = "garon_arrival"
		if active_rumor_id == "" and rumors.has("rumor_elin"):
			track_rumor("rumor_elin")
	elif resolved_event_id == "recruit_elin":
		complete_rumor("rumor_elin")
		pending_castle_event_id = "elin_arrival"
	pending_story_event_id = ""
	return "%s이(가) 동료로 합류했습니다!" % companion_name

func apply_battle_result(player_won: bool) -> void:
	var attacked_region_name: String = get_region_name(defense_region_id)
	var retreat_region_name: String = get_region_name(attack_region_id)

	if player_won and defense_region_id != "":
		set_region_owner(defense_region_id, PLAYER_FACTION)
		last_battle_result = "player_win"
		var messages: Array[String] = ["승리! %s를 점령했습니다." % attacked_region_name]
		var rewards: Dictionary = get_region_rewards(defense_region_id)
		apply_rewards(rewards)
		queue_story_event_by_region(defense_region_id)
		if has_pending_story_event():
			messages.append("새로운 동료 이벤트가 발생했습니다.")
		var unlocked_messages: Array[String] = []
		var unlock_class_id: String = str(regions[defense_region_id].get("unlock_class", ""))
		if unlock_class_id != "" and unlock_unit_class(unlock_class_id):
			var class_data: Dictionary = UNIT_CLASSES.get(unlock_class_id, {})
			unlocked_messages.append("신규 병종 해금: %s" % str(class_data.get("display_name", unlock_class_id)))
		messages.append("획득 보상: %s" % format_reward_text(rewards))
		var suggested_use_text: String = str(regions[defense_region_id].get("suggested_use", ""))
		if suggested_use_text == "":
			suggested_use_text = "병영·훈련장 강화에 사용할 수 있습니다."
		messages.append("보상 활용: %s" % suggested_use_text)
		messages.append_array(unlocked_messages)
		messages.append_array(grant_companion_exp_on_victory(int(rewards.get("companion_exp", COMPANION_EXP_PER_WIN))))
		last_battle_message = "\n".join(messages)
	else:
		last_battle_result = "player_lose"
		last_battle_message = "패배... %s로 후퇴합니다." % retreat_region_name

	clear_selection()

func get_region_rewards(region_id: String) -> Dictionary:
	if not regions.has(region_id):
		return DEFAULT_BATTLE_REWARD.duplicate(true)
	var region_data: Dictionary = regions[region_id]
	var reward_data: Dictionary = region_data.get("reward", DEFAULT_BATTLE_REWARD)
	return reward_data.duplicate(true)

func apply_rewards(reward_data: Dictionary) -> void:
	gold += int(reward_data.get("gold", 0))
	supplies += int(reward_data.get("supplies", 0))
	materials += int(reward_data.get("materials", 0))
	renown += int(reward_data.get("renown", 0))

func get_resource_display_name(resource_id: String) -> String:
	var resource_definition: Dictionary = RESOURCE_DEFINITIONS.get(resource_id, {})
	return str(resource_definition.get("display_name", resource_id))

func get_resource_amount(resource_id: String) -> int:
	match resource_id:
		"gold":
			return gold
		"supplies":
			return supplies
		"materials":
			return materials
		"renown":
			return renown
		_:
			return 0

func get_resource_summary_text() -> String:
	var parts: Array[String] = []
	var ordered_ids: Array[String] = ["gold", "supplies", "materials", "renown"]
	for resource_id: String in ordered_ids:
		parts.append("%s %d" % [get_resource_display_name(resource_id), get_resource_amount(resource_id)])
	return " / ".join(parts)

func format_reward_text(reward_data: Dictionary) -> String:
	var reward_parts: Array[String] = []
	var ordered_ids: Array[String] = ["gold", "supplies", "materials", "renown"]
	for resource_id: String in ordered_ids:
		var amount: int = int(reward_data.get(resource_id, 0))
		if amount > 0:
			reward_parts.append("%s +%d" % [get_resource_display_name(resource_id), amount])
	var companion_exp: int = int(reward_data.get("companion_exp", 0))
	if companion_exp > 0:
		reward_parts.append("동료 EXP +%d" % companion_exp)
	if reward_parts.is_empty():
		return "없음"
	return " / ".join(reward_parts)

func get_soldier_hp_bonus() -> float:
	return float(barracks_level - 1) * 18.0

func get_soldier_attack_bonus() -> float:
	return float(training_ground_level) * 1.6

func get_army_morale_bonus() -> float:
	return float(lodging_level) * 0.8

func get_upgrade_cost(upgrade_key: String) -> Dictionary:
	match upgrade_key:
		"barracks":
			return {"gold": 70 + barracks_level * 45, "materials": 30 + barracks_level * 18}
		"training_ground":
			return {"gold": 65 + training_ground_level * 50, "materials": 35 + training_ground_level * 20}
		"lodging":
			return {"gold": 55 + lodging_level * 40, "materials": 25 + lodging_level * 16}
		_:
			return {"gold": 9999, "materials": 9999}

func try_upgrade_castle(upgrade_key: String) -> bool:
	var cost: Dictionary = get_upgrade_cost(upgrade_key)
	var need_gold: int = int(cost.get("gold", 0))
	var need_materials: int = int(cost.get("materials", 0))
	if gold < need_gold or materials < need_materials:
		return false
	gold -= need_gold
	materials -= need_materials
	match upgrade_key:
		"barracks":
			barracks_level += 1
		"training_ground":
			training_ground_level += 1
		"lodging":
			lodging_level += 1
		_:
			return false
	return true

func has_companion_joined(companion_id: String) -> bool:
	if not companions.has(companion_id):
		return false
	var companion: Dictionary = companions[companion_id]
	return bool(companion.get("joined", false))

func get_available_rumor_ids() -> Array[String]:
	var rumor_ids: Array[String] = []
	var garon_joined: bool = has_companion_joined("garon")
	var elin_joined: bool = has_companion_joined("elin")
	var mira_joined: bool = has_companion_joined("mira")
	if not garon_joined and rumors.has("rumor_garon") and not bool(rumors["rumor_garon"].get("completed", false)):
		rumor_ids.append("rumor_garon")
	if garon_joined and not elin_joined and rumors.has("rumor_elin") and not bool(rumors["rumor_elin"].get("completed", false)):
		rumor_ids.append("rumor_elin")
	if garon_joined and elin_joined and not mira_joined and rumors.has("rumor_mira") and not bool(rumors["rumor_mira"].get("completed", false)):
		rumor_ids.append("rumor_mira")
	var unique_ids: Array[String] = []
	for rumor_id: String in rumor_ids:
		if not unique_ids.has(rumor_id):
			unique_ids.append(rumor_id)
	rumor_ids = unique_ids
	return rumor_ids

func update_pending_castle_event() -> void:
	if has_companion_joined("garon") and not completed_castle_events.has("garon_arrival"):
		pending_castle_event_id = "garon_arrival"
	elif has_companion_joined("elin") and not completed_castle_events.has("elin_arrival"):
		pending_castle_event_id = "elin_arrival"

func has_pending_castle_event() -> bool:
	return pending_castle_event_id != ""

func complete_castle_event(event_id: String) -> void:
	if not completed_castle_events.has(event_id):
		completed_castle_events.append(event_id)
	if pending_castle_event_id == event_id:
		pending_castle_event_id = ""
