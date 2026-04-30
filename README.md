# 군웅의 계절 (Season of Warlords)

Godot 4.6.2 + GDScript로 만드는 인디 전략 RPG 프로토타입입니다.

## 실행 방법 (Godot 4.6.2)
1. Godot **4.6.2** 에디터에서 이 폴더를 엽니다.
2. Project > Project Settings > Application에서 메인 씬이 `res://scenes/WorldMap.tscn`인지 확인합니다.
3. 실행(F5)하면 월드맵 씬이 시작됩니다.
4. 월드맵에서 아군(파란색) 지역을 먼저 클릭한 뒤, 인접한 적 지역을 클릭하면 전투 씬으로 이동합니다.

## 현재 구현된 기능
- `WorldMap.tscn`에 즉시 보이는 월드맵 UI 배치
  - `StatusLabel`, `MessageLabel`, `RegionContainer`
  - 6개 지역 노드(수도, 북부성, 동부평야, 서부관문, 남부항구, 중앙산맥)
- 지역별 소유 세력과 색상 표시
  - Player: 파란색
  - Red Kingdom: 빨간색
  - Green Kingdom: 초록색
  - Neutral: 회색
- 월드맵 클릭 규칙
  - 적 지역을 먼저 클릭하면: `먼저 아군 지역을 선택하세요`
  - 아군 선택 후 비인접 지역 클릭: `인접 지역이 아닙니다`
  - 아군 선택 후 인접 적 지역 클릭: `Battle.tscn` 전환
- `WorldMap.gd`가 월드맵 루트에 연결되어 있고 `_ready()`에서 로그 출력
  - `WorldMap ready - regions initialized`
- `Battle.tscn`에 `Battle Scene` 라벨 표시
- `Battle.gd`에서 아군 10 / 적군 10 유닛 자동 생성 및 전투 처리

## 아직 미구현된 기능
- 장수/부대 편성 시스템
- 내정/외교/경제 시스템
- 병과 상성/스킬/아이템
- AI 전략 고도화
- 고급 월드맵 연출(애니메이션, 경로선, 툴팁)
