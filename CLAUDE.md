# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

RBTL Game is an iOS/iPadOS eye movement training app developed in partnership with [Read Between the Lions](https://readbetweenthelions.org). The app trains users' saccadic eye movements (jump eye movements) to improve reading fluency through tapping exercises synchronized to a metronome.

**Target Platform:** iPad (primary), iPhone (secondary)
**Framework:** SwiftUI
**Minimum iOS:** 17.0

## Build & Run

This project requires Xcode. Open the `.xcodeproj` file in Xcode.

```bash
# Build from command line
xcodebuild -scheme RBTLGame -destination 'platform=iOS Simulator,name=iPad Pro 13-inch (M4)'

# Run tests
xcodebuild test -scheme RBTLGame -destination 'platform=iOS Simulator,name=iPad Pro 13-inch (M4)'
```

For development, use Xcode's Run button (Cmd+R) targeting an iPad simulator or connected device.

## Architecture

```
RBTLGame/
├── RBTLGameApp.swift      # App entry point
├── ContentView.swift       # Main menu / navigation root
├── Views/
│   ├── GameView.swift      # Active training session UI
│   └── SettingsView.swift  # BPM, target size, sound settings
├── Models/
│   ├── Target.swift        # Tap target data model
│   └── GameSettings.swift  # User preferences model
├── Services/
│   ├── GameEngine.swift    # Game loop, scoring, target sequencing
│   └── MetronomeService.swift  # Audio timing with AVAudioEngine
└── Resources/              # Assets, sounds (future)
```

## Key Components

**GameEngine** (`Services/GameEngine.swift`): Main game loop using `@MainActor`. Manages target activation sequence, hit/miss tracking, and coordinates with MetronomeService. Uses `Timer` for beat-synchronized updates.

**MetronomeService** (`Services/MetronomeService.swift`): Low-latency audio using `AVAudioEngine` and `AVAudioPlayerNode`. Generates click sounds programmatically for precise timing at 60-250 BPM.

**GameView** (`Views/GameView.swift`): Full-screen training interface. Targets are positioned using `GeometryReader` for responsive layout. Touch handling via SwiftUI's `onTapGesture`.

## Game Mechanics

- User sees multiple target circles on screen
- One target activates (highlights) on each metronome beat
- User must tap the active target before the next beat
- BPM range: 60-250 (configurable in Settings)
- At 250 BPM, users tap ~4 times per second

## Settings Persistence

User preferences stored via `@AppStorage` (UserDefaults):
- `bpm`: Beats per minute (Double, default 60)
- `targetSize`: Target circle diameter in points (Double, default 80)
- `soundEnabled`: Metronome audio toggle (Bool, default true)

## Development Notes

- iPad-first design: ensure layouts work on larger screens with appropriate target spacing
- Audio latency is critical: avoid adding processing that could delay metronome ticks
- Touch responsiveness matters at high BPM: keep tap handlers lightweight
- Test on physical iPad for accurate timing assessment (simulators may have audio latency)
