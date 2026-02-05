import SwiftUI
import AVFoundation

enum GamePhase {
    case ready       // Waiting to start
    case countdown   // 5, 4, 3, 2, 1, Go
    case playing     // Active gameplay
    case finished    // All targets attempted
}

@MainActor
class GameEngine: ObservableObject {
    // Published state for UI
    @Published var targets: [Target] = []
    @Published var gridCharacters: [[GridCharacter]] = []  // For Mode B display
    @Published var phase: GamePhase = .ready
    @Published var countdownValue: String = ""
    @Published var currentBPM: Int = 60
    @Published var hits: Int = 0
    @Published var misses: Int = 0

    // Game configuration
    var gameMode: GameMode = .blankMiddle
    var characterType: CharacterType = .numbers
    var balloonSize: CGFloat = 80

    // Timing window configuration (in seconds)
    private let preBeatWindow: TimeInterval = 0.300   // 300ms before beat
    private let postBeatWindow: TimeInterval = 0.400  // 400ms after beat

    // Internal state
    private var metronome: MetronomeService?
    private var timer: Timer?
    private var currentSequenceIndex: Int = 0
    private var soundEnabled: Bool = true
    private var gameStartTime: Date?
    private var beatInterval: TimeInterval {
        60.0 / Double(currentBPM)
    }

    var accuracyPercent: Int {
        let total = hits + misses
        guard total > 0 else { return 100 }
        return Int((Double(hits) / Double(total)) * 100)
    }

    var isRunning: Bool {
        phase == .playing
    }

    func setupGame(
        gameMode: GameMode,
        characterType: CharacterType,
        bpm: Int,
        balloonSize: CGFloat,
        screenSize: CGSize
    ) {
        self.gameMode = gameMode
        self.characterType = characterType
        self.currentBPM = bpm
        self.balloonSize = balloonSize

        // Load sound preference
        soundEnabled = UserDefaults.standard.bool(forKey: "soundEnabled")
        if UserDefaults.standard.object(forKey: "soundEnabled") == nil {
            soundEnabled = true
        }

        // Setup metronome
        metronome = MetronomeService(bpm: bpm, soundEnabled: soundEnabled)

        // Generate pattern based on mode
        switch gameMode {
        case .blankMiddle:
            setupModeA(screenSize: screenSize)
        case .fullGrid:
            setupModeB(screenSize: screenSize)
        }

        phase = .ready
        hits = 0
        misses = 0
        currentSequenceIndex = 0
        gameStartTime = nil
    }

    // MARK: - Mode A: Blank Middle (2 columns)

    private func setupModeA(screenSize: CGSize) {
        let characters = generateCharacters(count: 20)

        let leftX = screenSize.width * 0.15
        let rightX = screenSize.width * 0.85

        // Calculate vertical spacing for 10 rows
        let topMargin: CGFloat = 80
        let bottomMargin: CGFloat = 120
        let availableHeight = screenSize.height - topMargin - bottomMargin
        let rowSpacing = availableHeight / 9  // 9 gaps for 10 rows

        var newTargets: [Target] = []
        var sequenceIndex = 0

        for row in 0..<10 {
            let y = topMargin + CGFloat(row) * rowSpacing

            // Left target
            newTargets.append(Target(
                position: CGPoint(x: leftX, y: y),
                state: .pending,
                character: characters[row * 2],
                isUnderlined: false,
                sequenceIndex: sequenceIndex,
                balloonSize: balloonSize
            ))
            sequenceIndex += 1

            // Right target
            newTargets.append(Target(
                position: CGPoint(x: rightX, y: y),
                state: .pending,
                character: characters[row * 2 + 1],
                isUnderlined: false,
                sequenceIndex: sequenceIndex,
                balloonSize: balloonSize
            ))
            sequenceIndex += 1
        }

        targets = newTargets
    }

    // MARK: - Mode B: Full Grid (10x10)

    struct GridCharacter: Identifiable {
        let id = UUID()
        let character: String
        let row: Int
        let column: Int
        var isTarget: Bool
        var targetIndex: Int?  // Index into targets array if this is a target
    }

    private func setupModeB(screenSize: CGSize) {
        let allCharacters = generateCharacters(count: 100)

        // Determine target positions: 1 in left half (0-4), 1 in right half (5-9) per row
        var targetPositions: [(row: Int, col: Int)] = []
        for row in 0..<10 {
            let leftCol = Int.random(in: 0...4)
            let rightCol = Int.random(in: 5...9)
            targetPositions.append((row, leftCol))
            targetPositions.append((row, rightCol))
        }

        // Sort by sequence: left-to-right within each row, top-to-bottom
        targetPositions.sort { a, b in
            if a.row != b.row { return a.row < b.row }
            return a.col < b.col
        }

        // Calculate grid layout
        let horizontalMargin: CGFloat = 40
        let topMargin: CGFloat = 80
        let bottomMargin: CGFloat = 120
        let availableWidth = screenSize.width - (horizontalMargin * 2)
        let availableHeight = screenSize.height - topMargin - bottomMargin
        let cellWidth = availableWidth / 10
        let cellHeight = availableHeight / 10

        // Create grid characters
        var grid: [[GridCharacter]] = []
        var newTargets: [Target] = []

        for row in 0..<10 {
            var rowChars: [GridCharacter] = []
            for col in 0..<10 {
                let charIndex = row * 10 + col
                let isTarget = targetPositions.contains { $0.row == row && $0.col == col }

                var gridChar = GridCharacter(
                    character: allCharacters[charIndex],
                    row: row,
                    column: col,
                    isTarget: isTarget,
                    targetIndex: nil
                )

                if isTarget {
                    let sequenceIndex = targetPositions.firstIndex { $0.row == row && $0.col == col }!
                    gridChar.targetIndex = newTargets.count

                    let x = horizontalMargin + (CGFloat(col) + 0.5) * cellWidth
                    let y = topMargin + (CGFloat(row) + 0.5) * cellHeight

                    newTargets.append(Target(
                        position: CGPoint(x: x, y: y),
                        state: .pending,
                        character: allCharacters[charIndex],
                        isUnderlined: true,
                        sequenceIndex: sequenceIndex,
                        balloonSize: balloonSize
                    ))
                }

                rowChars.append(gridChar)
            }
            grid.append(rowChars)
        }

        gridCharacters = grid
        targets = newTargets
    }

    // MARK: - Character Generation

    private func generateCharacters(count: Int) -> [String] {
        var characters: [String] = []
        let pool: [String]

        switch characterType {
        case .numbers:
            pool = (0...9).map { String($0) }
        case .letters:
            pool = "ABCDEFGHIJKLMNOPQRSTUVWXYZ".map { String($0) }
        }

        for _ in 0..<count {
            characters.append(pool.randomElement()!)
        }

        return characters
    }

    // MARK: - Timing Calculations

    /// Returns the expected beat time for a given sequence index
    private func expectedBeatTime(for sequenceIndex: Int) -> Date {
        guard let start = gameStartTime else { return Date.distantFuture }
        return start.addingTimeInterval(Double(sequenceIndex) * beatInterval)
    }

    /// Checks if a tap at the current time is within the valid timing window for a target
    private func isWithinTimingWindow(for sequenceIndex: Int) -> Bool {
        let now = Date()
        let expectedBeat = expectedBeatTime(for: sequenceIndex)
        let timeDelta = now.timeIntervalSince(expectedBeat)

        // Valid window: -300ms (pre-beat) to +400ms (post-beat)
        return timeDelta >= -preBeatWindow && timeDelta <= postBeatWindow
    }

    // MARK: - Game Flow

    func startCountdown() {
        phase = .countdown
        currentSequenceIndex = 0

        let countdownSequence = ["5", "4", "3", "2", "1", "Go"]
        var index = 0

        let interval = beatInterval

        // Show first countdown immediately
        countdownValue = countdownSequence[0]
        metronome?.playTick()
        index = 1

        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self = self else { return }

                if index < countdownSequence.count {
                    self.countdownValue = countdownSequence[index]
                    self.metronome?.playTick()
                    index += 1
                } else {
                    // Countdown finished, start playing
                    self.countdownValue = ""
                    self.startPlaying()
                }
            }
        }
    }

    private func startPlaying() {
        timer?.invalidate()
        phase = .playing
        gameStartTime = Date()
        currentSequenceIndex = 0

        // Play first beat immediately (target 0's beat)
        processBeat()

        // Start metronome timer for subsequent beats
        timer = Timer.scheduledTimer(withTimeInterval: beatInterval, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.processBeat()
            }
        }
    }

    private func processBeat() {
        guard phase == .playing else { return }
        guard currentSequenceIndex < targets.count else { return }

        // Play metronome tick
        metronome?.playTick()

        // Schedule miss check after grace period for the current target
        let targetSequenceIndex = currentSequenceIndex
        DispatchQueue.main.asyncAfter(deadline: .now() + postBeatWindow) { [weak self] in
            Task { @MainActor in
                self?.checkForMiss(sequenceIndex: targetSequenceIndex)
            }
        }

        // Advance to next target
        currentSequenceIndex += 1

        // Check if this was the last target
        if currentSequenceIndex >= targets.count {
            // Schedule finish after last target's grace period
            DispatchQueue.main.asyncAfter(deadline: .now() + postBeatWindow) { [weak self] in
                Task { @MainActor in
                    self?.finishGame()
                }
            }
            timer?.invalidate()
            timer = nil
        }
    }

    /// Called after grace period to mark target as missed if still pending
    private func checkForMiss(sequenceIndex: Int) {
        guard phase == .playing || phase == .finished else { return }

        guard let targetIdx = targets.firstIndex(where: { $0.sequenceIndex == sequenceIndex }) else {
            return
        }

        // If still pending after grace period, mark as miss
        if targets[targetIdx].state == .pending {
            targets[targetIdx].state = .miss
            misses += 1
        }
    }

    func handleTap(at location: CGPoint) {
        guard phase == .playing else { return }

        // Find which pending target the user tapped (spatially)
        for i in targets.indices {
            let target = targets[i]
            guard target.state == .pending else { continue }

            let distance = hypot(location.x - target.position.x, location.y - target.position.y)
            let hitRadius = target.balloonSize / 2

            if distance <= hitRadius {
                // User tapped this target - check timing
                if isWithinTimingWindow(for: target.sequenceIndex) {
                    // Hit! Within timing window
                    targets[i].state = .hit
                    hits += 1
                    metronome?.playPop()
                } else {
                    // Tapped correct target but outside timing window
                    targets[i].state = .miss
                    misses += 1
                    metronome?.playTick()
                }
                return
            }
        }

        // Tapped empty space - no action
    }

    private func finishGame() {
        phase = .finished
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        phase = .ready
        hits = 0
        misses = 0
        currentSequenceIndex = 0
        gameStartTime = nil
    }
}
