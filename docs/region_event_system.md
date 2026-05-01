# Region Event System

## Main Concept
A **Region** is a place on the map. A **RegionEvent** is a situation happening in that place.

Ownership and event resolution are separate.

Example: **Ancient Ruins** may belong to Cheongram, but an unresolved mystery can still exist inside the ruins.

## Region Fields
Suggested Region fields:

- `id`
- `display_name`
- `owner_faction`
- `is_discovered`
- `is_unlocked`
- `position`
- `action_type`
- `objective_type`
- `region_event_id`
- `encounter_flavor`
- `special_rule`
- `reward_preview`
- `unlock_conditions`

## RegionEvent Fields
Suggested RegionEvent fields:

- `event_id`
- `region_id`
- `title`
- `description`
- `action_type`
- `objective_type`
- `required_flags`
- `resolved_flag`
- `completion_result`
- `reward`
- `recruit_id`
- `unlock_class_id`
- `changes_ownership`

## action_type
- `conquest`: frontline assault to seize control.
- `exploration`: investigate ruins/interiors/unknown hazards.
- `rescue`: recover civilians/allies under threat.
- `defense`: hold existing territory against attack.
- `escort`: move target safely through danger.
- `ambush`: sudden engagement with tactical disadvantage/variance.
- `choice`: narrative decision node with branching outcomes.
- `training`: controlled challenge for progression unlocks.
- `resource`: operation focused on supply/material recovery.
- `ritual`: magical or high-risk event with interruption stakes.

## objective_type
- `rout`: defeat all hostile forces.
- `survive`: endure until timer/wave condition completes.
- `protect`: keep key unit/objective alive.
- `investigate`: uncover/resolve hidden cause.
- `choice`: select among consequences.
- `unlock`: complete condition to unlock class/system/path.
- `boss`: defeat elite threat.
- `resource`: secure extraction quota or cache.

## Completion Rules
- **conquest**
  - may change ownership.

- **exploration**
  - does not change ownership.
  - resolves `region_event_id`.
  - may unlock companion/class/story.

- **rescue**
  - may recruit or increase reputation.

- **defense**
  - protects existing ownership/resources.

- **choice**
  - may not involve battle.

- **training**
  - unlocks practice/reward.

- **resource**
  - gives resources.

- **ambush**
  - battle variant.

- **ritual**
  - investigation/boss/interruption event.

## Ancient Ruins / Mira Example
- region: Ancient Ruins
- owner: Cheongram/player
- action_type: exploration
- objective_type: investigate
- event_id: ancient_ruins_mira
- completion: Mira joins, Sorcerer unlocks, event resolved, ownership unchanged

## Early Region Variety Table
| Region | Recommended action_type | Recommended objective_type | Design intent |
|---|---|---|---|
| Old Training Yard | training | unlock | Teach progression + class unlock flow. |
| Abandoned Farm | resource | resource | Early economy stabilization and logistics pressure relief. |
| Collapsed Outpost | defense or exploration | survive or investigate | Frontier instability with mixed military/investigation tone. |
| Wild Dog Forest Path | ambush | survive | Sudden threat pacing and formation stress test. |
| Refugee Camp | choice or rescue | choice or protect | Civilian consequence and reputation framing. |
| Red Banner Scout Party | conquest or ambush | rout | Military pressure before major fortress chain. |
| Ancient Ruins | exploration | investigate | Player-owned region with unresolved mystery and recruitment payoff. |
