import Foundation

enum GameMode: String, CaseIterable {
    case blankMiddle = "Blank Middle"
    case fullGrid = "Full Grid"
}

enum CharacterType: String, CaseIterable {
    case numbers = "Numbers"
    case letters = "Letters"
}

struct GameSettings {
    var bpm: Int = 60  // 50-150 beats per minute
    var balloonSize: CGFloat = 80
    var soundEnabled: Bool = true
    var gameMode: GameMode = .blankMiddle
    var characterType: CharacterType = .numbers

    // BPM options for dropdown (50-150 in steps of 10)
    static let bpmOptions = stride(from: 50, through: 150, by: 10).map { $0 }

    // Computed property: seconds between beats
    var beatInterval: TimeInterval {
        60.0 / Double(bpm)
    }
}
