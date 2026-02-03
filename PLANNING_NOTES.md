# RBTL Game - Implementation Plan

**Date:** 2026-02-02
**Source:** Discussion based on `rbtl_patterns.pdf` (Richard F. Meier, OD FCOVD & Janice Rossall, 2021)

---

## Summary

Replace the existing 5-target game with two new eye movement training modes based on the RBTL patterns PDF:
- **Mode A (Blank Middle)**: 10 rows × 2 columns, targets on far left and right
- **Mode B (Full Grid)**: 10×10 character grid with 20 underlined targets

Both modes share: blue dots on all targets from start, user clears dots by tapping in sequence, tap feedback (hit → dot disappears, miss → red circle), forward-only progression.

---

## Design Decisions

| Aspect | Decision |
|--------|----------|
| Original mode | **Remove** - replaced by Mode A and Mode B |
| Visibility | All targets visible with blue dots from start |
| Active indicator | **None** - user clears dots in sequence naturally |
| Timing | One metronome beat per tap (20 beats per exercise) |
| Progression | Left → Right → Next Row (top to bottom) |
| Hit feedback | Blue dot disappears |
| Miss feedback | Red circle appears (no retry allowed) |
| Dot size | User-configurable via **slider** |
| BPM range | **50-150 BPM** in increments of 10 (dropdown) |
| Pattern generation | Random with new seed each app launch |
| Restart behavior | **Return to setup screen** - user can pick all parameters fresh |

---

## User Flow

### 1. Launch / Setup Screen
User makes three choices before starting:
1. **Character type**: Numbers (0-9) or Letters (A-Z)
2. **Game mode**: Mode A (Blank Middle) or Mode B (Full Grid)
3. **Metronome speed**: Dropdown with 50, 60, 70, 80, 90, 100, 110, 120, 130, 140, 150 BPM

Plus: Dot size setting (slider)

### 2. Press Start → Countdown
- Pattern appears on screen with all blue dots visible
- Countdown overlays on pattern: **5, 4, 3, 2, 1, Go**
- Each number displays for one metronome beat interval (shows the tempo)
- Gives user time to prepare and understand the rhythm

### 3. Game Play
- User taps targets in sequence (left-right, top-bottom)
- Metronome beats guide the pace
- Blue dots disappear on correct taps
- Red circles appear on misses
- No going back - forward only

### 4. Restart Button
- Always visible during gameplay
- Returns to setup screen so user can adjust any settings
- New random pattern generated on next start

### 5. Completion
- All 20 targets attempted
- Show results (hits/misses) - *details TBD*

---

## Pattern Types (from rbtl_patterns.pdf)

### Mode A: "Blank in the Middle"
- **Layout:** 10 rows, each with 2 targets - one on far LEFT, one on far RIGHT
- **Blank space** in the middle simulates the span of a line of text
- **Flow:** User taps: left → right → next line (top to bottom)
- **Purpose:** Train eyes to sweep from far left to far right of a "line"

### Mode B: Full Grid with Underlined Targets
- **Layout:** 10 rows × 10 characters = 100 characters per exercise
- **Character types:** Numbers (0-9) or letters (A-Z)
- **Target marking:** Two characters per line are **underlined** with blue dots
  - One in the LEFT half (positions 1-5)
  - One in the RIGHT half (positions 6-10)
- **Purpose:** Train student to make exactly **two fixations per line**
- **Cognitive load:** User must visually search and identify the underlined target

---

## Mode A Layout

```
┌────────────────────────────────────────┐
│                                        │
│  7●                              3●    │  Row 1
│                                        │
│  2●                              8●    │  Row 2
│                                        │
│  ...                            ...    │  Rows 3-9
│                                        │
│  5●                              1●    │  Row 10
│                                        │
│                [Restart]               │
└────────────────────────────────────────┘

● = Blue dot on target
Tap sequence: L1 → R1 → L2 → R2 → ... → L10 → R10
```

- Position left targets at ~15% screen width
- Position right targets at ~85% screen width
- Distribute rows evenly across screen height

---

## Mode B Layout

```
┌────────────────────────────────────────┐
│  7  3  9̲● 1  4  |  8  2̲● 6  0  5     │  Row 1
│  2  8̲● 4  6  1  |  5  9  3̲● 7  0     │  Row 2
│  ...                                   │  Rows 3-10
│                                        │
│                [Restart]               │
└────────────────────────────────────────┘

̲● = underlined character with blue dot (tappable target)
Plain characters = non-targets (no interaction)
```

- 100 characters in 10×10 grid
- Each row: 1 target in columns 1-5, 1 target in columns 6-10
- Random position within each half
- Blue dots only on the 20 underlined targets

---

## Visual Feedback States

| State | Appearance | When |
|-------|------------|------|
| Pending | Character with blue dot | Not yet reached in sequence |
| Hit | Character only (dot gone) | Correctly tapped |
| Miss | Character with red circle | Wrong tap or skipped |

No "active" highlight - user learns the left-right-down pattern naturally.

---

## Files to Modify

| File | Changes |
|------|---------|
| `Models/Target.swift` | Add `TargetState` enum, character, sequenceIndex |
| `Models/GameSettings.swift` | Add GameMode, CharacterType enums; BPM 50-150; dotSize |
| `Services/GameEngine.swift` | Mode A/B layouts, random generation, countdown, tap handling |
| `Views/GameView.swift` | New TargetView, countdown overlay, restart button |
| `Views/SettingsView.swift` | Setup screen with all options |
| `ContentView.swift` | Navigation flow: Setup → Game |

---

## Implementation Order

1. Update GameSettings with new enums, BPM range
2. Update Target model with state enum, character, sequence index
3. Create Setup screen with mode/character/BPM/dot size selection
4. Update GameEngine with Mode A layout and random generation
5. Update GameView with new TargetView, countdown overlay, restart button
6. Test Mode A end-to-end
7. Add Mode B to GameEngine (grid layout, underlines)
8. Test Mode B end-to-end
9. Remove old 5-target code

---

## Open Questions (to revisit)

1. **Results screen**: What stats to show after completion? (hits, misses, accuracy %, time?)
2. **Sound**: Different sounds for hit vs miss, or just metronome click?

---

## Why Touch Instead of Voice?

The original paper exercises have students speak the numbers/letters aloud. For the iPad app, touch/tap is preferred because:
- Voice recognition cannot work reliably at required speeds (up to 150 BPM)
- Touch provides immediate, unambiguous feedback
- Works in noisy environments (classrooms)

---

*Last updated: 2026-02-02*
