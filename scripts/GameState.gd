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

# 지역 원본 데이터 (인접 정보 포함)
var regions: Dictionary = {}
# 현재 지역 소유권 (region_id -> faction_id)
var ownership: Dictionary = {}

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
	clear_selection()
	last_battle_result = ""
	last_battle_message = ""

func clear_selection() -> void:
	selected_region_id = ""
	attack_region_id = ""
	defense_region_id = ""

func get_region_owner(region_id: String) -> int:
	return ownership.get(region_id, -1)

func set_region_owner(region_id: String, faction_id: int) -> void:
	if ownership.has(region_id):
		ownership[region_id] = faction_id

func is_adjacent(from_region_id: String, to_region_id: String) -> bool:
	if not regions.has(from_region_id):
		return false
	var neighbors: Array = regions[from_region_id].get("adjacent", [])
	return to_region_id in neighbors

func set_battle_context(attacker_region_id: String, defender_region_id: String) -> void:
	attack_region_id = attacker_region_id
	defense_region_id = defender_region_id

func apply_battle_result(player_won: bool) -> void:
	var target_region_name := ""
	if defense_region_id != "" and regions.has(defense_region_id):
		target_region_name = str(regions[defense_region_id].get("name", "미지의 지역"))

	if player_won:
		# 플레이어 승리 시 방어 지역 소유권이 플레이어로 변경됩니다.
		if defense_region_id != "":
			set_region_owner(defense_region_id, PLAYER_FACTION)
		last_battle_result = "player_win"
		last_battle_message = "승리! %s를 점령했습니다." % target_region_name
	else:
		last_battle_result = "player_lose"
		if attack_region_id != "" and regions.has(attack_region_id):
			var retreat_region_name := str(regions[attack_region_id].get("name", "아군 지역"))
			last_battle_message = "패배... %s로 후퇴합니다." % retreat_region_name
		else:
			last_battle_message = "패배... 아군 지역으로 후퇴합니다."

	clear_selection()
