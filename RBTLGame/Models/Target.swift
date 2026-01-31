import SwiftUI

struct Target: Identifiable {
    let id = UUID()
    var position: CGPoint
    var isActive: Bool = false
    var size: CGFloat = 80
}
