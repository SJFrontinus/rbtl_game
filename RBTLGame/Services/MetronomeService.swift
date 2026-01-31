import AVFoundation

class MetronomeService {
    private var audioEngine: AVAudioEngine?
    private var playerNode: AVAudioPlayerNode?
    private var tickBuffer: AVAudioPCMBuffer?

    private var timer: Timer?
    private var bpm: Int
    private var soundEnabled: Bool

    init(bpm: Int, soundEnabled: Bool = true) {
        self.bpm = bpm
        self.soundEnabled = soundEnabled

        if soundEnabled {
            setupAudio()
        }
    }

    private func setupAudio() {
        audioEngine = AVAudioEngine()
        playerNode = AVAudioPlayerNode()

        guard let engine = audioEngine, let player = playerNode else { return }

        engine.attach(player)

        // Create a simple tick sound
        let sampleRate: Double = 44100
        let duration: Double = 0.05  // 50ms tick
        let frameCount = AVAudioFrameCount(sampleRate * duration)

        guard let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1),
              let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else {
            return
        }

        buffer.frameLength = frameCount

        // Generate a simple click sound (sine wave burst)
        if let channelData = buffer.floatChannelData?[0] {
            for frame in 0..<Int(frameCount) {
                let frequency: Float = 880.0  // A5 note
                let amplitude: Float = 0.5
                let envelope = 1.0 - (Float(frame) / Float(frameCount))  // Decay
                channelData[frame] = sin(2.0 * .pi * frequency * Float(frame) / Float(sampleRate)) * amplitude * envelope
            }
        }

        tickBuffer = buffer

        engine.connect(player, to: engine.mainMixerNode, format: format)

        do {
            try engine.start()
        } catch {
            print("Audio engine failed to start: \(error)")
        }
    }

    func start() {
        guard soundEnabled else { return }

        let interval = 60.0 / Double(bpm)

        // Play immediately on start
        playTick()

        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.playTick()
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        playerNode?.stop()
    }

    func setBPM(_ newBPM: Int) {
        bpm = newBPM
        if timer != nil {
            stop()
            start()
        }
    }

    private func playTick() {
        guard let player = playerNode, let buffer = tickBuffer else { return }
        player.scheduleBuffer(buffer, at: nil, options: [], completionHandler: nil)
        if !player.isPlaying {
            player.play()
        }
    }

    deinit {
        stop()
        audioEngine?.stop()
    }
}
