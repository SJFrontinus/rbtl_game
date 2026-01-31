import SwiftUI

struct SettingsView: View {
    @AppStorage("bpm") private var bpm: Double = 60
    @AppStorage("targetSize") private var targetSize: Double = 80
    @AppStorage("soundEnabled") private var soundEnabled: Bool = true

    var body: some View {
        Form {
            Section("Tempo") {
                VStack(alignment: .leading) {
                    Text("Beats Per Minute: \(Int(bpm))")
                    Slider(value: $bpm, in: 60...250, step: 5)
                }

                // Quick presets
                HStack {
                    ForEach([60, 100, 150, 200], id: \.self) { preset in
                        Button("\(preset)") {
                            bpm = Double(preset)
                        }
                        .buttonStyle(.bordered)
                    }
                }
            }

            Section("Display") {
                VStack(alignment: .leading) {
                    Text("Target Size: \(Int(targetSize))pt")
                    Slider(value: $targetSize, in: 40...150, step: 10)
                }
            }

            Section("Audio") {
                Toggle("Metronome Sound", isOn: $soundEnabled)
            }

            Section("About") {
                Link("Read Between the Lions", destination: URL(string: "https://readbetweenthelions.org")!)
                Text("Eye movement training to improve reading fluency")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle("Settings")
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
