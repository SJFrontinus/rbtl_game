import AVFoundation

class MetronomeService {
    private var audioEngine: AVAudioEngine?
    private var playerNode: AVAudioPlayerNode?
    private var popPlayerNode: AVAudioPlayerNode?
    private var tickBuffer: AVAudioPCMBuffer?
    private var popBuffer: AVAudioPCMBuffer?

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
        popPlayerNode = AVAudioPlayerNode()

        guard let engine = audioEngine,
              let player = playerNode,
              let popPlayer = popPlayerNode else { return }

        engine.attach(player)
        engine.attach(popPlayer)

        let sampleRate: Double = 44100

        // Create metronome tick sound
        tickBuffer = createTickBuffer(sampleRate: sampleRate)

        // Create pop sound
        popBuffer = createPopBuffer(sampleRate: sampleRate)

        guard let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1) else {
            return
        }

        engine.connect(player, to: engine.mainMixerNode, format: format)
        engine.connect(popPlayer, to: engine.mainMixerNode, format: format)

        do {
            try engine.start()
        } catch {
            print("Audio engine failed to start: \(error)")
        }
    }

    private func createTickBuffer(sampleRate: Double) -> AVAudioPCMBuffer? {
        let duration: Double = 0.05  // 50ms tick
        let frameCount = AVAudioFrameCount(sampleRate * duration)

        guard let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1),
              let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else {
            return nil
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

        return buffer
    }

    private func createPopBuffer(sampleRate: Double) -> AVAudioPCMBuffer? {
        let duration: Double = 0.08  // 80ms pop
        let frameCount = AVAudioFrameCount(sampleRate * duration)

        guard let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1),
              let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else {
            return nil
        }

        buffer.frameLength = frameCount

        // Generate a "pop" sound - quick noise burst with fast decay
        if let channelData = buffer.floatChannelData?[0] {
            for frame in 0..<Int(frameCount) {
                let progress = Float(frame) / Float(frameCount)
                let envelope = pow(1.0 - progress, 3.0)  // Rapid decay

                // Mix of frequencies for a "pop" character
                let freq1: Float = 400.0
                let freq2: Float = 800.0
                let freq3: Float = 1200.0

                let sample = (
                    sin(2.0 * .pi * freq1 * Float(frame) / Float(sampleRate)) * 0.4 +
                    sin(2.0 * .pi * freq2 * Float(frame) / Float(sampleRate)) * 0.3 +
                    sin(2.0 * .pi * freq3 * Float(frame) / Float(sampleRate)) * 0.2
                ) * envelope * 0.6

                channelData[frame] = sample
            }
        }

        return buffer
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
        popPlayerNode?.stop()
    }

    func setBPM(_ newBPM: Int) {
        bpm = newBPM
        if timer != nil {
            stop()
            start()
        }
    }

    func playTick() {
        guard soundEnabled, let player = playerNode, let buffer = tickBuffer else { return }
        player.scheduleBuffer(buffer, at: nil, options: [], completionHandler: nil)
        if !player.isPlaying {
            player.play()
        }
    }

    func playPop() {
        guard soundEnabled, let player = popPlayerNode, let buffer = popBuffer else { return }
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
