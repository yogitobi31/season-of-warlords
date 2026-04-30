extends RefCounted
class_name RegionData

# Godot 4.6 MVP용 고정 지역 데이터
# 각 지역은 id, name, owner_faction, position, neighbors 정보를 가집니다.

static func get_regions() -> Dictionary:
	return {
		"capital": {
			"id": "capital",
			"name": "수도",
			"owner_faction": 0,
			"position": Vector2(280, 220),
			"neighbors": ["north_fortress", "west_gate", "central_mountains"]
		},
		"north_fortress": {
			"id": "north_fortress",
			"name": "북부성",
			"owner_faction": 1,
			"position": Vector2(560, 130),
			"neighbors": ["capital", "eastern_plains"]
		},
		"eastern_plains": {
			"id": "eastern_plains",
			"name": "동부평야",
			"owner_faction": 2,
			"position": Vector2(860, 230),
			"neighbors": ["north_fortress", "central_mountains"]
		},
		"west_gate": {
			"id": "west_gate",
			"name": "서부관문",
			"owner_faction": 3,
			"position": Vector2(170, 430),
			"neighbors": ["capital", "south_port"]
		},
		"south_port": {
			"id": "south_port",
			"name": "남부항구",
			"owner_faction": 1,
			"position": Vector2(420, 590),
			"neighbors": ["west_gate", "central_mountains"]
		},
		"central_mountains": {
			"id": "central_mountains",
			"name": "중앙산맥",
			"owner_faction": 2,
			"position": Vector2(700, 440),
			"neighbors": ["capital", "eastern_plains", "south_port"]
		}
	}
