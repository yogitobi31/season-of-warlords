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

const COMPANION_EXP_PER_WIN := 30
const COMPANION_LEVELUP_EXP := 100

# 지역 원본 데이터 (인접 정보 포함)
var regions: Dictionary = {}
# 현재 지역 소유권 (region_id -> faction_id)
var ownership: Dictionary = {}

# 동료 데이터 (companion_id -> Dictionary)
var companions: Dictionary = {}

# 기본 성채 데이터 (MVP)
var fortress_data := {
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
	# 게임 시작 시 지역 데이터를 초기화합니다.
	initialize_regions()

func initialize_regions() -> void:
	# RegionData가 가진 정적 데이터를 복사하여 런타임 상태를 만듭니다.
	regions = RegionData.get_regions()
	ownership.clear()
	for region_id in regions.keys():
		ownership[region_id] = regions[region_id]["owner"]
	initialize_companions()
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

func get_total_companion_bonuses() -> Dictionary:
	var bonuses := {
		"max_hp": 0.0,
		"attack_power": 0.0,
		"move_speed": 0.0,
		"attack_range": 0.0
	}
	for companion in get_joined_companions():
		var bonus_type := str(companion.get("battle_bonus_type", ""))
		if bonuses.has(bonus_type):
			bonuses[bonus_type] += float(companion.get("battle_bonus_value", 0.0))
	return bonuses

func grant_companion_exp_on_victory() -> Array[String]:
	var level_up_messages: Array[String] = []
	for companion_id in companions.keys():
		var companion: Dictionary = companions[companion_id]
		if not companion.get("joined", false):
			continue
		var exp := int(companion.get("exp", 0)) + COMPANION_EXP_PER_WIN
		var level := int(companion.get("level", 1))
		while exp >= COMPANION_LEVELUP_EXP:
			exp -= COMPANION_LEVELUP_EXP
			level += 1
			level_up_messages.append("%s 레벨 %d 달성!" % [companion.get("name", companion_id), level])
		companion["exp"] = exp
		companion["level"] = level
		companions[companion_id] = companion
	return level_up_messages

func unlock_companions_by_region(region_id: String) -> Array[String]:
	var join_messages: Array[String] = []
	for companion_id in companions.keys():
		var companion: Dictionary = companions[companion_id]
		if companion.get("joined", false):
			continue
		if str(companion.get("unlock_region_id", "")) == region_id:
			companion["joined"] = true
			companions[companion_id] = companion
			join_messages.append("%s이(가) 동료로 합류했습니다!" % companion.get("name", companion_id))
	return join_messages

func apply_battle_result(player_won: bool) -> void:
	var attacked_region_name := get_region_name(defense_region_id)
	var retreat_region_name := get_region_name(attack_region_id)

	# 플레이어 승리 시 방어 지역 소유권이 플레이어로 변경됩니다.
	if player_won and defense_region_id != "":
		set_region_owner(defense_region_id, PLAYER_FACTION)
		last_battle_result = "player_win"
		var messages := ["승리! %s를 점령했습니다." % attacked_region_name]
		messages.append_array(unlock_companions_by_region(defense_region_id))
		messages.append_array(grant_companion_exp_on_victory())
		last_battle_message = "\n".join(messages)
	else:
		last_battle_result = "player_lose"
		last_battle_message = "패배... %s로 후퇴합니다." % retreat_region_name

	clear_selection()
