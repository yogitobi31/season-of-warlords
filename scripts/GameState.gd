extends Node

const PLAYER_FACTION := 0
const RED_KINGDOM_FACTION := 1
const GREEN_KINGDOM_FACTION := 2
const NEUTRAL_FACTION := 3

const FACTION_NAMES := {
	PLAYER_FACTION: "Player",
	RED_KINGDOM_FACTION: "Red Kingdom",
	GREEN_KINGDOM_FACTION: "Green Kingdom",
	NEUTRAL_FACTION: "Neutral"
}

const FACTION_COLORS := {
	PLAYER_FACTION: Color("3b82f6"),
	RED_KINGDOM_FACTION: Color("ef4444"),
	GREEN_KINGDOM_FACTION: Color("22c55e"),
	NEUTRAL_FACTION: Color("9ca3af")
}

var regions: Dictionary = {}
var ownership: Dictionary = {}

var selected_region_id: String = ""
var attack_region_id: String = ""
var defense_region_id: String = ""
var last_battle_result: String = ""

func _ready() -> void:
	initialize_regions()

func initialize_regions() -> void:
	regions = RegionData.get_regions()
	ownership.clear()
	for region_id in regions.keys():
		ownership[region_id] = regions[region_id]["owner_faction"]
	clear_selection()
	last_battle_result = ""

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
	var neighbors: Array = regions[from_region_id].get("neighbors", [])
	return to_region_id in neighbors

func set_battle_context(attacker_region_id: String, defender_region_id: String) -> void:
	attack_region_id = attacker_region_id
	defense_region_id = defender_region_id

func apply_battle_result(player_won: bool) -> void:
	if player_won and defense_region_id != "":
		set_region_owner(defense_region_id, PLAYER_FACTION)
		last_battle_result = "player_win"
	else:
		last_battle_result = "player_lose"
	clear_selection()
