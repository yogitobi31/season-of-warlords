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
		"r1": {"name": "청람 성채", "owner": 0, "pos": Vector2(220, 180), "adjacent": ["r2", "r4"], "danger": "낮음", "recommended": "기본 병력", "reward": {"gold": 40, "materials": 10, "renown": 0, "companion_exp": 20}},
		"r2": {"name": "북부 감시요새", "owner": 1, "pos": Vector2(460, 160), "adjacent": ["r1", "r3", "r5", "s1"], "danger": "보통", "recommended": "병영 Lv.2", "reward": {"gold": 90, "materials": 25, "renown": 8, "companion_exp": 35}},
		"r3": {"name": "서리숲 관문", "owner": 1, "pos": Vector2(730, 210), "adjacent": ["r2", "r6", "s3"], "danger": "높음", "recommended": "훈련장 Lv.2", "reward": {"gold": 100, "materials": 30, "renown": 12, "companion_exp": 40}},
		"r4": {"name": "서부 협곡로", "owner": 0, "pos": Vector2(290, 410), "adjacent": ["r1", "r5", "r7", "s2"], "danger": "보통", "recommended": "병영 Lv.2", "reward": {"gold": 70, "materials": 20, "renown": 4, "companion_exp": 30}},
		"r5": {"name": "중앙 평원", "owner": 2, "pos": Vector2(560, 390), "adjacent": ["r2", "r4", "r6", "r8"], "danger": "높음", "recommended": "병영 Lv.2 + 훈련장 Lv.2", "reward": {"gold": 120, "materials": 35, "renown": 10, "companion_exp": 45}},
		"r6": {"name": "남해 항구", "owner": 2, "pos": Vector2(860, 390), "adjacent": ["r3", "r5"], "danger": "높음", "recommended": "훈련장 Lv.2", "reward": {"gold": 110, "materials": 28, "renown": 9, "companion_exp": 42}},
		"r7": {"name": "고대 유적지", "owner": 0, "pos": Vector2(240, 610), "adjacent": ["r4", "r8"], "danger": "보통", "recommended": "숙소 Lv.1", "reward": {"gold": 80, "materials": 18, "renown": 5, "companion_exp": 30}},
		"r8": {"name": "녹림 산맥", "owner": 2, "pos": Vector2(540, 610), "adjacent": ["r5", "r7"], "danger": "높음", "recommended": "병영 Lv.2 + 숙소 Lv.2", "reward": {"gold": 130, "materials": 40, "renown": 13, "companion_exp": 48}},
		"s1": {"name": "버려진 광산", "owner": 1, "pos": Vector2(430, 40), "adjacent": ["r2"], "danger": "낮음", "recommended": "기본 병력", "reward": {"gold": 30, "materials": 55, "renown": 2, "companion_exp": 20}},
		"s2": {"name": "난민 수레길", "owner": 2, "pos": Vector2(120, 470), "adjacent": ["r4"], "danger": "낮음", "recommended": "숙소 Lv.1", "reward": {"gold": 35, "materials": 12, "renown": 18, "companion_exp": 22}},
		"s3": {"name": "늑대 숲", "owner": 2, "pos": Vector2(930, 220), "adjacent": ["r3"], "danger": "보통", "recommended": "훈련장 Lv.1", "reward": {"gold": 85, "materials": 16, "renown": 6, "companion_exp": 34}}
	}
