# CastleHub Pixel Art Assets

이 폴더는 CastleHub 화면을 픽셀아트 기반 RPG 허브처럼 보이게 만들기 위한 에셋 구조입니다.

## 폴더 구조

```text
assets/pixel/castlehub/
  characters/
    leon_idle.png
    garon_idle.png
    elin_idle.png
    mira_idle.png

  objects/
    rumor_board.png
    training_dummy.png
    castle_gate.png
    management_desk.png
    banner_blue.png
    crate_small.png

  tiles/
    courtyard_ground_tile.png
    castle_wall_tile.png
    stone_trim_tile.png

  ui/
    dialogue_frame.png
    command_menu_frame.png
```

## 원칙

- 보이는 픽셀아트와 클릭 판정은 분리합니다.
- Sprite2D 또는 TextureRect는 비주얼용으로 사용합니다.
- 클릭은 투명 Button, TextureButton, Control hotspot, Area2D 중 하나로 처리합니다.
- PNG가 아직 없으면 기존 placeholder fallback이 안전하게 표시되어야 합니다.
- 오브젝트 위에는 짧은 이름만 표시합니다. 예: 레온, 게시판, 성문, 훈련장, 관리.
- 행동 문구는 오브젝트 위가 아니라 하단 대화창 또는 contextual command menu에 표시합니다.

## Generating temporary assets

Run:

```bash
python tools/generate_temp_pixel_assets.py
```

Then commit generated PNGs locally if needed:

```bash
git add assets/pixel/castlehub
git commit -m "Add generated temporary CastleHub pixel assets"
git push
```
