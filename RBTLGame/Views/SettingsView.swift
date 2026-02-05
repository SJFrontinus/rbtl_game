import SwiftUI

struct SetupView: View {
    @AppStorage("bpm") private var bpm: Int = 60
    @AppStorage("balloonSize") private var balloonSize: Double = 80
    @AppStorage("soundEnabled") private var soundEnabled: Bool = true

    @State private var gameMode: GameMode = .blankMiddle
    @State private var characterType: CharacterType = .numbers
    @State private var navigateToGame = false

    var body: some View {
        VStack(spacing: 30) {
            Text("RBTL Training")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Eye Movement Training")
                .font(.title3)
                .foregroundColor(.secondary)

            Spacer()

            // Game Mode Selection
            VStack(alignment: .leading, spacing: 10) {
                Text("Game Mode")
                    .font(.headline)

                Picker("Game Mode", selection: $gameMode) {
                    ForEach(GameMode.allCases, id: \.self) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
            }
            .padding(.horizontal)

            // Character Type Selection
            VStack(alignment: .leading, spacing: 10) {
                Text("Character Type")
                    .font(.headline)

                Picker("Character Type", selection: $characterType) {
                    ForEach(CharacterType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(.segmented)
            }
            .padding(.horizontal)

            // BPM Selection (Dropdown)
            VStack(alignment: .leading, spacing: 10) {
                Text("Metronome Speed")
                    .font(.headline)

                Picker("BPM", selection: $bpm) {
                    ForEach(GameSettings.bpmOptions, id: \.self) { bpmValue in
                        Text("\(bpmValue) BPM").tag(bpmValue)
                    }
                }
                .pickerStyle(.menu)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
            }
            .padding(.horizontal)

            // Balloon Size Slider
            VStack(alignment: .leading, spacing: 10) {
                Text("Balloon Size: \(Int(balloonSize))pt")
                    .font(.headline)

                Slider(value: $balloonSize, in: 40...120, step: 10)
                    .padding(.horizontal)

                HStack {
                    Text("Small")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("Large")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
            }
            .padding(.horizontal)

            Spacer()

            // Start Button
            Button(action: {
                navigateToGame = true
            }) {
                Text("Start Training")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 60)
                    .padding(.vertical, 18)
                    .background(Color.blue)
                    .cornerRadius(15)
            }
            .navigationDestination(isPresented: $navigateToGame) {
                GameView(
                    gameMode: gameMode,
                    characterType: characterType,
                    bpm: bpm,
                    balloonSize: CGFloat(balloonSize)
                )
            }

            // Sound Toggle
            Toggle("Sound Enabled", isOn: $soundEnabled)
                .padding(.horizontal, 40)
                .padding(.bottom, 20)
        }
        .padding()
    }
}

#Preview {
    NavigationStack {
        SetupView()
    }
}
