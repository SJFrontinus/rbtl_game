import Foundation

struct GameSettings {
    var bpm: Int = 60  // 60-250 beats per minute
    var targetSize: CGFloat = 80
    var soundEnabled: Bool = true

    // Computed property: milliseconds between beats
    var beatInterval: TimeInterval {
        60.0 / Double(bpm)
    }
}
