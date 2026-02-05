# RBTL Game - Implementation Plan

**Date:** 2026-02-03
**Source:** Discussion based on `rbtl_patterns.pdf` (Richard F. Meier, OD FCOVD & Janice Rossall, 2021)

---

## Summary

Replace the existing 5-target game with two new eye movement training modes based on the RBTL patterns PDF:
- **Mode A (Blank Middle)**: 10 rows × 2 columns, targets on far left and right
- **Mode B (Full Grid)**: 10×10 character grid with 20 underlined targets

Both modes share:
- **Translucent blue "balloon"** overlay on each target (letter visible through it)
- User "pops" balloons by tapping in sequence
- **Hit**: Balloon pops with a **pop sound**
- **Miss**: Balloon turns **translucent red**, metronome continues (no pop)
- Forward-only progression

---

## Implementation Status

| Component | Status |
|-----------|--------|
| GameSettings (enums, BPM 50-150) | DONE |
| Target model (state, character) | DONE |
| MetronomeService (pop sound) | DONE |
| Setup screen | DONE |
| GameEngine (Mode A + B) | DONE |
| GameView (balloons, countdown) | DONE |
| Build successful | YES |

---

## Design Decisions

| Aspect | Decision |
|--------|----------|
| Original mode | **Remove** - replaced by Mode A and Mode B |
| Target marker | **Translucent blue balloon** overlay (letter visible through it) |
| Active indicator | **None** - user pops balloons in sequence naturally |
| Timing | One metronome beat per tap (20 beats per exercise) |
| Progression | Left → Right → Next Row (top to bottom) |
| Hit feedback | Balloon pops (disappears) + **pop sound** |
| Miss feedback | Balloon turns **translucent red** + metronome tick (no pop sound) |
| Balloon size | User-configurable via **slider** (40-120pt) |
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

Plus: Balloon size setting (slider)

### 2. Press Start → Countdown
- Pattern appears on screen with all blue balloons visible
- Countdown overlays on pattern: **5, 4, 3, 2, 1, Go**
- Each number displays for one metronome beat interval (shows the tempo)
- Gives user time to prepare and understand the rhythm

### 3. Game Play
- User taps targets in sequence (left-right, top-bottom)
- Metronome beats guide the pace
- **Hit**: Balloon pops (disappears) with pop sound
- **Miss**: Balloon turns red, metronome continues
- No going back - forward only

### 4. Restart Button
- Always visible during gameplay (except during countdown)
- Returns to setup screen so user can adjust any settings
- New random pattern generated on next start

### 5. Completion
- All 20 targets attempted
- Game ends (stats display deferred for now)

---

## Visual & Audio Feedback

### Visual States
| State | Appearance | When |
|-------|------------|------|
| Pending | Character with **translucent blue balloon** | Not yet reached in sequence |
| Hit | Character only (balloon popped/gone) | Correctly tapped |
| Miss | Character with **translucent red balloon** | Wrong tap or timed out |

### Audio Feedback
| Event | Sound |
|-------|-------|
| Hit | **Pop sound** (balloon popping) |
| Miss | Metronome tick only (no pop) |
| Countdown | Metronome tick |

---

## Mode A Layout (Blank Middle)

```
┌────────────────────────────────────────┐
│                                        │
│  (7)                            (3)    │  Row 1
│                                        │
│  (2)                            (8)    │  Row 2
│                                        │
│  ...                            ...    │  Rows 3-9
│                                        │
│  (5)                            (1)    │  Row 10
│                                        │
│                [Restart]               │
└────────────────────────────────────────┘

(X) = Character with translucent blue balloon overlay
Tap sequence: L1 → R1 → L2 → R2 → ... → L10 → R10
```

- Position left targets at ~15% screen width
- Position right targets at ~85% screen width
- Distribute rows evenly across screen height

---

## Mode B Layout (Full Grid)

```
┌────────────────────────────────────────┐
│  7  3 (9̲) 1  4  |  8 (2̲) 6  0  5     │  Row 1
│  2 (8̲) 4  6  1  |  5  9 (3̲) 7  0     │  Row 2
│  ...                                   │  Rows 3-10
│                                        │
│                [Restart]               │
└────────────────────────────────────────┘

(X̲) = underlined character with translucent blue balloon
Plain characters = non-targets (gray, no balloon)
```

- 100 characters in 10×10 grid
- Each row: 1 target in columns 1-5, 1 target in columns 6-10
- Random position within each half
- Target characters are **underlined AND have blue balloon**

---

## Future Enhancements (not in initial version)

1. **Results/stats screen**: Deferred - the real reward is progressing to higher speeds with minimal errors

---

## Why Touch Instead of Voice?

The original paper exercises have students speak the numbers/letters aloud. For the iPad app, touch/tap is preferred because:
- Voice recognition cannot work reliably at required speeds (up to 150 BPM)
- Touch provides immediate, unambiguous feedback
- Works in noisy environments (classrooms)

---

*Last updated: 2026-02-03*
