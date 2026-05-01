# Season of Warlords UI Style Guide

## Core Rules
1. One piece of information appears in only one place.
2. Do not place long text directly over the central map or scene.
3. Region buttons show only name, danger, and optional rumor marker.
4. Detailed information belongs in panels.
5. Buttons must not stretch vertically.
6. Korean tooltip/info text must have enough width.
7. Close buttons must always remain visible.
8. UI spacing should follow 8/12/16/24 px rhythm.
9. Before adding content, check for overlap.
10. Map area should contain only nodes, route lines, and minimal markers.

## WorldMap Rules
- Left panel: current rumor/objective/controls.
- Right panel: selected region detail.
- Lower right panel: companions and unlocked classes.
- Central map: region nodes and route lines only.
- Keep map nodes compact; action/objective/event flavor text stays in side panels.

## CastleHub Rules
- Castle courtyard is the scene.
- Management popup uses fixed sections:
  title, summary, upgrade info, buttons, close.
- Upgrade details appear in only one info panel.

## WorldMap Region Node Rules
- Region nodes should be compact markers, not large text buttons.
- Visible marker: about 18~24 px.
- Click area: about 44~48 px.
- Region names are hidden by default.
- Region names appear on hover or selection.
- Details belong in the right-side panel.
- Do not solve map clutter by making larger spacing forever.
- Future map should support pan/zoom and zoom-level-based labels.
