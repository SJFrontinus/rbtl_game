import SwiftUI

struct GameView: View {
    // Game settings passed from setup
    let gameMode: GameMode
    let characterType: CharacterType
    let bpm: Int
    let balloonSize: CGFloat

    @StateObject private var gameEngine = GameEngine()
    @Environment(\.dismiss) private var dismiss

    @State private var hasSetup = false
    @State private var tapLocations: [TapMarker] = []

    struct TapMarker: Identifiable {
        let id = UUID()
        let location: CGPoint
        let timestamp: Date
    }

    var body: some View {
        GeometryReader { geometry in
            let gridFontSize = calculateGridFontSize(geometry: geometry)

            ZStack {
                // Background with tap gesture
                Color.white
                    .ignoresSafeArea()
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onEnded { value in
                                // Record tap location for debugging (stays visible)
                                tapLocations.append(TapMarker(location: value.location, timestamp: Date()))
                                gameEngine.handleTap(at: value.location)
                            }
                    )

                // Mode B: Full grid with all characters (targets and non-targets)
                if gameMode == .fullGrid {
                    FullGridView(
                        gameEngine: gameEngine,
                        geometry: geometry,
                        fontSize: gridFontSize,
                        balloonSize: balloonSize
                    )
                    .allowsHitTesting(false)  // Let touches pass through to background
                } else {
                    // Mode A: Just render targets with balloons
                    ForEach(gameEngine.targets) { target in
                        BalloonTargetView(
                            target: target,
                            showUnderline: false,
                            fontSize: gridFontSize
                        )
                    }
                    .allowsHitTesting(false)  // Let touches pass through to background
                }

                // Tap location markers (debugging)
                ForEach(tapLocations) { marker in
                    TapMarkerView()
                        .position(marker.location)
                }
                .allowsHitTesting(false)  // Don't block subsequent taps

                // Countdown overlay
                if gameEngine.phase == .countdown && !gameEngine.countdownValue.isEmpty {
                    CountdownOverlay(value: gameEngine.countdownValue)
                        .allowsHitTesting(false)  // Let taps pass through for pre-beat window
                }

                // Controls overlay
                VStack {
                    // Stats bar
                    HStack {
                        Text("\(bpm) BPM")
                            .fontWeight(.medium)
                        Spacer()
                        if gameEngine.phase == .playing || gameEngine.phase == .finished {
                            Text("Hits: \(gameEngine.hits)")
                            Spacer()
                            Text("Misses: \(gameEngine.misses)")
                        }
                    }
                    .font(.subheadline)
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(Color.white.opacity(0.95))

                    Spacer()

                    // Bottom controls
                    HStack(spacing: 30) {
                        if gameEngine.phase == .ready {
                            Button("Start") {
                                gameEngine.startCountdown()
                            }
                            .font(.title2)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 40)
                            .padding(.vertical, 15)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }

                        // Restart button (always visible except during countdown)
                        if gameEngine.phase != .countdown {
                            Button("Restart") {
                                dismiss()
                            }
                            .font(.title3)
                            .padding(.horizontal, 30)
                            .padding(.vertical, 12)
                            .background(Color.gray.opacity(0.2))
                            .foregroundColor(.primary)
                            .cornerRadius(10)
                        }
                    }
                    .padding(.bottom, 30)
                }
            }
            .onAppear {
                if !hasSetup {
                    hasSetup = true
                    gameEngine.setupGame(
                        gameMode: gameMode,
                        characterType: characterType,
                        bpm: bpm,
                        balloonSize: balloonSize,
                        screenSize: geometry.size
                    )
                }
            }
        }
        .navigationBarHidden(true)
        .onDisappear {
            gameEngine.stop()
        }
    }

    private func calculateGridFontSize(geometry: GeometryProxy) -> CGFloat {
        let horizontalMargin: CGFloat = 40
        let topMargin: CGFloat = 80
        let bottomMargin: CGFloat = 120
        let availableWidth = geometry.size.width - (horizontalMargin * 2)
        let availableHeight = geometry.size.height - topMargin - bottomMargin
        let cellWidth = availableWidth / 10
        let cellHeight = availableHeight / 10
        return min(cellWidth, cellHeight) * 0.5
    }
}

// MARK: - Balloon Target View (for Mode A)

struct BalloonTargetView: View {
    let target: Target
    let showUnderline: Bool
    let fontSize: CGFloat

    var body: some View {
        ZStack {
            // Balloon (only show if not hit)
            if target.state != .hit {
                Circle()
                    .fill(balloonColor)
                    .frame(width: target.balloonSize, height: target.balloonSize)
            }

            // Character - centered at position
            Text(target.character)
                .font(.system(size: fontSize, weight: .bold, design: .monospaced))
                .foregroundColor(.black)

            // Underline - positioned below text
            if showUnderline && target.isUnderlined {
                Rectangle()
                    .fill(Color.black)
                    .frame(width: fontSize * 0.8, height: 2)
                    .offset(y: fontSize * 0.4)
            }
        }
        .position(target.position)
        .animation(.easeInOut(duration: 0.15), value: target.state)
    }

    private var balloonColor: Color {
        switch target.state {
        case .pending:
            return Color.blue.opacity(0.4)
        case .hit:
            return Color.clear
        case .miss:
            return Color.red.opacity(0.4)
        }
    }
}

// MARK: - Full Grid View for Mode B (renders ALL characters with same positioning)

struct FullGridView: View {
    @ObservedObject var gameEngine: GameEngine
    let geometry: GeometryProxy
    let fontSize: CGFloat
    let balloonSize: CGFloat

    var body: some View {
        let horizontalMargin: CGFloat = 40
        let topMargin: CGFloat = 80
        let bottomMargin: CGFloat = 120
        let availableWidth = geometry.size.width - (horizontalMargin * 2)
        let availableHeight = geometry.size.height - topMargin - bottomMargin
        let cellWidth = availableWidth / 10
        let cellHeight = availableHeight / 10

        ForEach(gameEngine.gridCharacters.flatMap { $0 }) { gridChar in
            let x = horizontalMargin + (CGFloat(gridChar.column) + 0.5) * cellWidth
            let y = topMargin + (CGFloat(gridChar.row) + 0.5) * cellHeight

            if gridChar.isTarget {
                // Target character with balloon
                if let targetIndex = gridChar.targetIndex,
                   targetIndex < gameEngine.targets.count {
                    let target = gameEngine.targets[targetIndex]

                    ZStack {
                        // Balloon (only show if not hit)
                        if target.state != .hit {
                            Circle()
                                .fill(balloonColor(for: target.state))
                                .frame(width: balloonSize, height: balloonSize)
                        }

                        // Character
                        Text(gridChar.character)
                            .font(.system(size: fontSize, weight: .bold, design: .monospaced))
                            .foregroundColor(.black)

                        // Underline
                        Rectangle()
                            .fill(Color.black)
                            .frame(width: fontSize * 0.8, height: 2)
                            .offset(y: fontSize * 0.4)
                    }
                    .position(x: x, y: y)
                    .animation(.easeInOut(duration: 0.15), value: target.state)
                }
            } else {
                // Non-target character (no balloon)
                Text(gridChar.character)
                    .font(.system(size: fontSize, weight: .regular, design: .monospaced))
                    .foregroundColor(.gray)
                    .position(x: x, y: y)
            }
        }
    }

    private func balloonColor(for state: TargetState) -> Color {
        switch state {
        case .pending:
            return Color.blue.opacity(0.4)
        case .hit:
            return Color.clear
        case .miss:
            return Color.red.opacity(0.4)
        }
    }
}

// MARK: - Tap Marker View (debugging)

struct TapMarkerView: View {
    var body: some View {
        ZStack {
            // Horizontal line
            Rectangle()
                .fill(Color.orange)
                .frame(width: 30, height: 4)
            // Vertical line
            Rectangle()
                .fill(Color.orange)
                .frame(width: 4, height: 30)
        }
    }
}

// MARK: - Countdown Overlay

struct CountdownOverlay: View {
    let value: String

    var body: some View {
        ZStack {
            // Semi-transparent background
            Color.black.opacity(0.3)
                .ignoresSafeArea()

            // Countdown number
            Text(value)
                .font(.system(size: 120, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.5), radius: 10, x: 0, y: 5)
        }
    }
}

#Preview {
    GameView(
        gameMode: .blankMiddle,
        characterType: .numbers,
        bpm: 60,
        balloonSize: 80
    )
}
