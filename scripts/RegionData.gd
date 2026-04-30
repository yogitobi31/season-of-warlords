extends RefCounted
class_name RegionData

# MVP용 고정 지역 데이터입니다.
# id: 고유 식별자
# name: 표시 이름
# owner: 초기 소유 세력
# pos: 월드맵에서의 표시 좌표
# adjacent: 인접 지역 목록

static func get_regions() -> Dictionary:
	return {
		"r1": {"name": "Bluevale Keep", "owner": 0, "pos": Vector2(220, 180), "adjacent": ["r2", "r4"]},
		"r2": {"name": "Northwatch Fort", "owner": 1, "pos": Vector2(460, 160), "adjacent": ["r1", "r3", "r5"]},
		"r3": {"name": "Elderpeak Mountains", "owner": 1, "pos": Vector2(730, 210), "adjacent": ["r2", "r6"]},
		"r4": {"name": "Westgate Pass", "owner": 0, "pos": Vector2(290, 410), "adjacent": ["r1", "r5", "r7"]},
		"r5": {"name": "Eastgrain Plains", "owner": 2, "pos": Vector2(560, 390), "adjacent": ["r2", "r4", "r6", "r8"]},
		"r6": {"name": "Southmere Harbor", "owner": 2, "pos": Vector2(860, 390), "adjacent": ["r3", "r5"]},
		"r7": {"name": "Silverwood Outpost", "owner": 0, "pos": Vector2(240, 610), "adjacent": ["r4", "r8"]},
		"r8": {"name": "Thornfield Crossing", "owner": 2, "pos": Vector2(540, 610), "adjacent": ["r5", "r7"]}
	}
