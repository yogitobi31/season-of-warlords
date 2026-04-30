extends RefCounted
class_name RegionData

# MVP용 고정 지역 데이터입니다.
# id: 고유 식별자
# name: 표시 이름
# owner: 초기 소유 세력
# pos: 월드맵에서의 표시 좌표
# adjacent: 인접 지역 목록
#
# 세계관 기준:
# - 삼국지 지명이 아니라 중세 판타지 변경 영지/성채/항구/산맥 분위기를 사용합니다.
# - 삼국지3는 세력 운영 참고작이고, 실제 컨셉 비중은 퍼스트퀸4식 실시간 부대 전투에 더 가깝습니다.

static func get_regions() -> Dictionary:
	return {
		"r1": {"name": "청람 성채", "owner": 0, "pos": Vector2(220, 180), "adjacent": ["r2", "r4"]},
		"r2": {"name": "북부 감시요새", "owner": 1, "pos": Vector2(460, 160), "adjacent": ["r1", "r3", "r5"]},
		"r3": {"name": "서리숲 관문", "owner": 1, "pos": Vector2(730, 210), "adjacent": ["r2", "r6"]},
		"r4": {"name": "서부 협곡로", "owner": 0, "pos": Vector2(290, 410), "adjacent": ["r1", "r5", "r7"]},
		"r5": {"name": "중앙 평원", "owner": 2, "pos": Vector2(560, 390), "adjacent": ["r2", "r4", "r6", "r8"]},
		"r6": {"name": "남해 항구", "owner": 2, "pos": Vector2(860, 390), "adjacent": ["r3", "r5"]},
		"r7": {"name": "고대 유적지", "owner": 0, "pos": Vector2(240, 610), "adjacent": ["r4", "r8"]},
		"r8": {"name": "녹림 산맥", "owner": 2, "pos": Vector2(540, 610), "adjacent": ["r5", "r7"]}
	}
