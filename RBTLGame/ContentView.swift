import SwiftUI

struct ContentView: View {
    @State private var isPlaying = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 40) {
                Text("Read Between the Lions")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Eye Movement Training")
                    .font(.title2)
                    .foregroundColor(.secondary)

                Spacer()

                NavigationLink(destination: GameView()) {
                    Text("Start Training")
                        .font(.title)
                        .padding(.horizontal, 60)
                        .padding(.vertical, 20)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(15)
                }

                NavigationLink(destination: SettingsView()) {
                    Text("Settings")
                        .font(.title2)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 15)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                }

                Spacer()
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
}
