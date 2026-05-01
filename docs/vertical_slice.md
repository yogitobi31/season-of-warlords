# Vertical Slice Target

## Purpose
Define what the first playable version must prove: **Season of Warlords** is a castle-centered strategy RPG where rumors drive expeditions, events vary by region, companions are core progression, and return-to-castle growth is the backbone.

## Target Experience
The player should understand that:
- CastleHub is home.
- Rumors create goals.
- WorldMap is for expeditions.
- Battles resolve some events.
- Not all regions are conquest.
- Companions join and appear in the castle.
- Castle growth and class unlocks begin early.

## Required Playable Flow
1. Start from Title  
2. Enter CastleHub  
3. Talk to Leon or see Leon as default leader  
4. Open Rumor Board  
5. Accept Garon rumor  
6. Go to WorldMap  
7. Select Northern Watch Fort  
8. Start expedition  
9. Complete battle  
10. Trigger Garon recruitment  
11. Return to CastleHub  
12. Garon appears in CastleHub  
13. Elin rumor appears  
14. Select Frost Forest Gate  
15. Complete battle/event  
16. Trigger Elin recruitment  
17. Return to CastleHub  
18. Elin appears in CastleHub  
19. Mira rumor appears  
20. Select Ancient Ruins  
21. Ancient Ruins is already player-owned  
22. Ancient Ruins has unresolved exploration event  
23. Start investigation  
24. Complete event  
25. Mira joins  
26. Sorcerer unlock flag/class becomes available  
27. Return to CastleHub  
28. Leon, Garon, Elin, Mira are visible or represented

## Acceptance Criteria
- [ ] Garon loop still works.
- [ ] Elin loop still works.
- [ ] Mira loop works.
- [ ] Ancient Ruins ownership does not change.
- [ ] Ancient Ruins event resolves.
- [ ] Sorcerer unlock is set.
- [ ] WorldMap compact markers are usable.
- [ ] Region detail panel explains the selected region.
- [ ] No major GDScript warnings.
- [ ] No Node.owner shadowing.
- [ ] No typed array assignment errors.

## Out of Scope for Current Vertical Slice
- Final graphics.
- Final sound.
- Full save system.
- Full faction AI.
- Full zoom/pan map.
- Large-scale war simulation.
- Polished battle AI.
