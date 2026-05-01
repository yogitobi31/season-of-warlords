# WorldMap UX Spec

## Main Principle
The WorldMap is an expedition/event selection screen, not a large button list.

## Layout
- **Center**: map markers and connection lines.
- **Right**: selected region detail panel.
- **Left/top**: current objective or campaign goal.
- **Bottom**: optional controls/log.

## Map Marker Rules
- Markers must be compact.
- Region names are not always visible.
- Names appear on hover/selection.
- Markers indicate state through color/shape/icon/text.
- Avoid tall buttons.
- Avoid long labels.
- Avoid overlapping text.

## Region Detail Panel
Should show:
- name
- owner
- action_type
- objective_type
- event status
- description
- special rule
- reward preview
- start button

## Start Button Text by Action Type
Use Korean labels if the project UI is Korean:

- conquest: 출정
- exploration: 조사 시작
- rescue: 구조하러 가기
- defense: 방어 준비
- escort: 호위 시작
- ambush: 진입
- choice: 상황 확인
- training: 훈련하기
- resource: 자원 회수
- ritual: 의식 저지

## Future Expansion
- zoom/pan later
- side scrolling later
- region chains later
- faction pressure later
- event icons later
