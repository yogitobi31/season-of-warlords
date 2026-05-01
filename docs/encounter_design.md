# Encounter Design: Region Action Variety (MVP)

## 왜 모든 지역이 점령전이 아니어야 하는가
월드맵의 모든 지역이 `클릭 → 동일한 전투 → 점령` 루프로만 작동하면 플레이 감각이 단조로워집니다.
특히 플레이어 소유 지역도 소문, 유적 조사, 선택형 사건을 담을 수 있어야 스토리와 전략이 자연스럽게 연결됩니다.

## 소유권과 미해결 사건 분리
- **소유권(ownership)**: 해당 지역의 정치/군사 지배 상태.
- **미해결 사건(unresolved event)**: 해당 지역에서 아직 처리되지 않은 조사/선택/훈련/자원 사건.

핵심 원칙:
- 플레이어 소유 지역이라도 사건이 남아 있을 수 있습니다.
- 사건 완료 시에는 소유권 변경 없이 사건만 해결됩니다.

## 지역 행동 유형 (action_type)
- conquest: 점령
- exploration: 조사
- rescue: 구출
- defense: 방어
- escort: 호위
- ambush: 매복
- choice: 선택
- training: 훈련
- resource: 자원
- ritual: 의식

## 조우 목표 유형 (objective_type)
- rout: 적 격파
- survive: 생존
- protect: 보호
- investigate: 조사
- choice: 선택
- unlock: 해금
- boss: 보스
- resource: 자원 확보

## 초반 지역 다양성 표
| 지역 | action_type | objective_type | 특수 규칙 |
|---|---|---|---|
| t1 낡은 훈련장 | training | unlock | 창병 해금 |
| t2 버려진 농가 | choice | choice | 보급 확보 또는 명성 선택 |
| t3 무너진 초소 | resource | unlock | 방패보병 해금 |
| t4 들개 숲길 | ambush | rout | 빠른 야수형 적 |
| t5 난민 야영지 | choice | choice | 명성 중심 선택 이벤트 |
| t6 붉은 깃발 정찰대 | ambush | rout | 북부 감시요새 전 정찰대 |
| r2 북부 감시요새 | conquest | rout | 가론 합류 |
| r3 서리숲 관문 | conquest | survive_or_rout | 엘린 합류 |
| r7 고대 유적지 | exploration | investigate | 미라 합류 / 소서러 해금 |

## Mira / 고대 유적지 방향
- `rumor_mira`는 `r7`(고대 유적지)를 대상으로 유지합니다.
- `r7`이 플레이어 소유여도 `exploration` 행동으로 진입 가능해야 합니다.
- 조사 성공 시:
  - 소유권은 유지
  - 지역 사건 해결 처리
  - `recruit_mira` 스토리 이벤트 연결

## 향후 확장 포인트
- 구출 임무 (rescue missions)
- 방어전 (defense battles)
- 호위전 (escort missions)
- 시간 제한 의식전 (timed rituals)
- 분기 선택형 사건 (branching choices)
- 숨겨진 발견 (hidden discoveries)
- 보스 결투 (boss duels)
- 지형 규칙/수정자 (terrain modifiers)
