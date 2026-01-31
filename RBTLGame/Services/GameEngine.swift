import SwiftUI
import AVFoundation

@MainActor
class GameEngine: ObservableObject {
    @Published var targets: [Target] = []
    @Published var isRunning = false
    @Published var currentBPM: Int = 60
    @Published var hits: Int = 0
    @Published var misses: Int = 0

    private var metronome: MetronomeService?
    private var timer: Timer?
    private var currentTargetIndex: Int = 0

    var accuracyPercent: Int {
        let total = hits + misses
        guard total > 0 else { return 100 }
        return Int((Double(hits) / Double(total)) * 100)
    }

    func setupGame() {
        // Load settings
        currentBPM = Int(UserDefaults.standard.double(forKey: "bpm"))
        if currentBPM < 60 { currentBPM = 60 }

        let targetSize = UserDefaults.standard.double(forKey: "targetSize")
        let size = targetSize > 0 ? targetSize : 80

        // Create a grid of targets for eye movement training
        // These positions will be adjusted based on screen size
        let positions: [CGPoint] = [
            CGPoint(x: 200, y: 200),
            CGPoint(x: 600, y: 200),
            CGPoint(x: 200, y: 500),
            CGPoint(x: 600, y: 500),
            CGPoint(x: 400, y: 350),
        ]

        targets = positions.map { pos in
            Target(position: pos, isActive: false, size: size)
        }

        // Setup metronome
        let soundEnabled = UserDefaults.standard.bool(forKey: "soundEnabled")
        metronome = MetronomeService(bpm: currentBPM, soundEnabled: soundEnabled)
    }

    func toggleRunning() {
        if isRunning {
            pause()
        } else {
            start()
        }
    }

    func start() {
        isRunning = true
        metronome?.start()

        // Schedule target changes on each beat
        let interval = 60.0 / Double(currentBPM)
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.advanceTarget()
            }
        }
    }

    func pause() {
        isRunning = false
        metronome?.stop()
        timer?.invalidate()
        timer = nil
    }

    func stop() {
        pause()
        hits = 0
        misses = 0
        currentTargetIndex = 0

        // Deactivate all targets
        for i in targets.indices {
            targets[i].isActive = false
        }
    }

    func targetTapped(_ target: Target) {
        guard isRunning else { return }

        if target.isActive {
            hits += 1
        } else {
            misses += 1
        }
    }

    private func advanceTarget() {
        // Deactivate current target
        if !targets.isEmpty {
            targets[currentTargetIndex].isActive = false
        }

        // Move to next target (or random for variety)
        currentTargetIndex = (currentTargetIndex + 1) % targets.count

        // Activate new target
        if !targets.isEmpty {
            targets[currentTargetIndex].isActive = true
        }
    }
}
