import SwiftUI

enum TargetState {
    case pending   // Blue balloon, waiting to be tapped
    case hit       // Successfully tapped, balloon gone
    case miss      // Missed or wrong tap, red balloon
}

struct Target: Identifiable {
    let id = UUID()
    var position: CGPoint
    var state: TargetState = .pending
    var character: String
    var isUnderlined: Bool = false  // For Mode B targets
    var sequenceIndex: Int          // Order in tap sequence
    var balloonSize: CGFloat = 80

    // For backwards compatibility during transition
    var isActive: Bool {
        state == .pending
    }
}
