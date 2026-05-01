# Encounter Design (Early Vertical Slice)

## Core Principle
월드맵의 모든 지역이 `점령 전투`일 필요는 없습니다. 지역은 **원정/조사/선택**의 진입점이며, 행동 유형(action_type)에 따라 완료 규칙이 달라집니다.

## Region State Separation
- **Ownership(소유권)**: 어느 세력이 외부 지역을 통제하는지.
- **Discovery(발견)**: 지형/지역이 지도에 표시되는지.
- **Unlock(해금)**: 플레이어가 해당 지역 행동을 시작할 수 있는지.
- **Unresolved Local Event(미해결 지역 이벤트)**: 지역 내부 사건이 남아 있는지.
- **Resolved Local Event(해결된 지역 이벤트)**: 사건 해결 완료 상태.

중요: 플레이어 소유 지역이라도 미해결 지역 이벤트를 가질 수 있습니다.

## Action Types
- `conquest`: 점령, 소유권 변경 가능
- `exploration`: 조사/탐사, 소유권 미변경
- `rescue`: 구조 중심
- `defense`: 방어 성공 중심
- `escort`: 호위 목적
- `ambush`: 기습/매복 성격
- `choice`: 전투보다 선택 중심
- `training`: 훈련/해금 중심
- `resource`: 자원 확보 중심
- `ritual`: 의식 저지/보스 성격

## Objective Types
- `rout`, `survive`, `protect`, `investigate`, `choice`, `unlock`, `boss`, `resource`

## Early Region Variety (Current Pass)
- 낡은 훈련장: training / unlock
- 버려진 농가: choice / choice
- 무너진 초소: resource / unlock
- 들개 숲길: ambush / rout
- 난민 야영지: choice / choice
- 붉은 깃발 정찰대: ambush / rout
- 고대 유적지: exploration / investigate

## Ancient Ruins / Mira Example
- 고대 유적지(`r7`)는 청람(플레이어) 소유 지역.
- 하지만 `ancient_ruins_mira` 이벤트는 미해결로 유지 가능.
- 조사 완료 시:
  - 소유권은 유지
  - 지역 이벤트 해결 처리
  - 미라 동료 이벤트 진행
  - 소서러 해금 플래그 갱신

## Extension Guidance
향후 지역 추가 시 최소 필드 권장:
`id`, `display_name`, `owner_faction`, `is_discovered`, `is_unlocked`, `action_type`, `objective_type`, `region_event_id`, `encounter_flavor`, `special_rule`, `reward_preview`, `unlock_conditions`, `position`.
