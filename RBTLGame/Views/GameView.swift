import SwiftUI

struct GameView: View {
    @StateObject private var gameEngine = GameEngine()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                Color.black.opacity(0.05)
                    .ignoresSafeArea()

                // Target circles - user taps these
                ForEach(gameEngine.targets) { target in
                    TargetView(target: target) {
                        gameEngine.targetTapped(target)
                    }
                }

                // Stats overlay
                VStack {
                    HStack {
                        Text("BPM: \(gameEngine.currentBPM)")
                        Spacer()
                        Text("Hits: \(gameEngine.hits)")
                        Spacer()
                        Text("Accuracy: \(gameEngine.accuracyPercent)%")
                    }
                    .font(.headline)
                    .padding()
                    .background(Color.white.opacity(0.9))

                    Spacer()

                    // Controls
                    HStack(spacing: 30) {
                        Button(gameEngine.isRunning ? "Pause" : "Start") {
                            gameEngine.toggleRunning()
                        }
                        .font(.title2)
                        .padding()
                        .background(gameEngine.isRunning ? Color.orange : Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)

                        Button("Stop") {
                            gameEngine.stop()
                            dismiss()
                        }
                        .font(.title2)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            gameEngine.setupGame()
        }
        .onDisappear {
            gameEngine.stop()
        }
    }
}

struct TargetView: View {
    let target: Target
    let onTap: () -> Void

    var body: some View {
        Circle()
            .fill(target.isActive ? Color.blue : Color.gray.opacity(0.3))
            .frame(width: target.size, height: target.size)
            .position(target.position)
            .onTapGesture {
                onTap()
            }
            .animation(.easeInOut(duration: 0.1), value: target.isActive)
    }
}

#Preview {
    GameView()
}
