# RBTL Game - Planning Notes

## Context
This document captures planning discussions for extending the RBTL (Read Between the Lions) eye movement training app.

**Date:** 2026-02-01
**Source:** Discussion based on `rbtl_patterns.pdf` (Richard F. Meier, OD FCOVD & Januce Rossall, 2021)

---

## Current App Overview
The existing RBTLGame is an iOS/iPadOS app that:
- Trains saccadic eye movements to improve reading fluency
- Uses a metronome (60-250 BPM) to pace tap exercises
- Targets highlight on each beat; user taps before next beat
- At 250 BPM, users tap ~4 times per second

---

## PDF Pattern Types (from rbtl_patterns.pdf)

### Pattern Type 1: "Blank in the Middle" (Page 1)
- **Layout:** 10 rows, each with just 2 numbers - one on far LEFT, one on far RIGHT
- **Blank space** in the middle simulates the span of a line of text
- **Flow:** Student reads/touches: left number → right number → next line (top to bottom)
- **Purpose:** Train eyes to sweep from far left to far right of a "line" - the fundamental saccade pattern for reading
- **Example (upper left quadrant):** 9, 3, 1, 0, 3, 5... (reading left-right, top-bottom)

### Pattern Type 2: Letters Version (Page 2)
- Same concept as Pattern Type 1, but using **letters instead of numbers**
- Still "blank in the middle" format

### Pattern Type 3: Full Grid with Underlined Targets
*(PDF page labeled "Page 6" is physical page 3)*

- **Layout:** 10 rows × 10 characters = 100 characters per exercise
- **Character types:** Numbers (0-9) or letters (A-Z)
- **Target marking:** Two characters per line are **underlined**
  - One underlined character in the LEFT half (positions 1-5)
  - One underlined character in the RIGHT half (positions 6-10)
  - Positions vary somewhat randomly within each half (not always at exact edges)
- **Purpose:** Train student to make exactly **two fixations per line**
  - First fixation: scan left side, find the underlined character
  - Second fixation: scan right side, find the underlined character
  - Then progress to next line
- **Cognitive load:** Student must visually search and identify the underlined target among 8 distractors per line
- **Key insight:** The underlined targets force the student's eyes to actually *find* something, not just mechanically tap left-right. This adds visual discrimination to the saccade training.

### Pattern Type 4: Two-Digit Numbers (Pages 4-5, 7+)
- Similar to Pattern Type 3 but with **two-digit numbers** (10-99)
- Increases difficulty/complexity

---

## Game Adaptation Ideas

### Why Touch Instead of Voice?
- Original paper exercises have students **speak** the numbers/letters aloud
- For the iPad app, **touch/tap** is preferred because:
  - Voice recognition cannot work reliably at the required speeds (up to 250 BPM = 4+ items/second)
  - Touch provides immediate, unambiguous feedback
  - Works in noisy environments (classrooms)

### Proposed Display Modes

#### Mode A: "Blank Middle" Display
- Show only **one character on far left** OR **one character on far right**
- Large, clear character display
- Mimics the paper pattern where middle is blank
- Student taps the character, then it moves to the opposite side for next beat

#### Mode B: "Full Grid" Display
- Show **10 rows × 10 characters** (numbers or letters)
- All 100 characters visible at once
- **Two targets per line** are marked (underlined or highlighted)
- Student must:
  1. Visually locate the left-half target
  2. Tap it
  3. Visually locate the right-half target
  4. Tap it
  5. Move to next line

### Target Indication Options
1. **Underline** - matches paper version; student must find the underlined character
2. **Blue dot/highlight** - more visible; could be used for easier difficulty levels
3. **Progressive reveal** - start with obvious highlighting, reduce to subtle underline as student improves

### Pattern Generation
- **Predetermined patterns:** Load from a set of pre-built exercises (like the PDF)
- **Dynamic generation:** Algorithmically create random patterns following the rules:
  - Characters are random and non-meaningful
  - Left target always in positions 1-5
  - Right target always in positions 6-10
  - Vary exact positions for unpredictability

---

## Open Questions

1. **Timing model:**
   - Should metronome beat = one tap? Or one line (two taps)?
   - Current app: one beat = one target. May need adjustment for two-targets-per-line mode.

2. **Scoring:**
   - Score accuracy (correct target tapped)?
   - Score speed (tap before next beat)?
   - Track eye movement patterns? (would require eye tracking hardware)

3. **Progression:**
   - Start with Mode A (simpler), advance to Mode B?
   - Start with numbers, advance to letters?
   - Start with highlighted targets, advance to underlined?

4. **Visual design:**
   - Font size for 10×10 grid on iPad?
   - Spacing to encourage proper saccade distance?
   - Portrait vs landscape orientation?

---

## Next Steps
*(To be determined in future discussions)*

- [ ] Define MVP feature set
- [ ] Design UI mockups for new modes
- [ ] Determine pattern data format
- [ ] Plan integration with existing GameEngine/MetronomeService

---

*This document will be updated as planning continues.*
