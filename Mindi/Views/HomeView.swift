//
//  HomeView.swift
//  Mindi
//
//  Created by Riv Sal on 11/9/25.
//

import SwiftUI
import Combine
import AVFoundation

// MARK: - Animated Background
struct AnimatedGradientBackground: View {
    @State private var animateGradient = false
    @State private var animateParticles = false

    var body: some View {
        ZStack {
            // Dark background base
            Color.black
                .ignoresSafeArea()

            // Animated flowing gradients
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.9, green: 0.85, blue: 0.8),  // Warm beige
                    Color(red: 0.85, green: 0.82, blue: 0.78), // Soft taupe
                    Color(red: 0.75, green: 0.72, blue: 0.68)  // Medium gray-beige
                ]),
                startPoint: animateGradient ? .topLeading : .bottomLeading,
                endPoint: animateGradient ? .bottomTrailing : .topTrailing
            )
            .opacity(0.15)
            .blur(radius: 30)
            .ignoresSafeArea()

            // Second gradient layer for depth
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.95, green: 0.9, blue: 0.85),  // Light cream
                    Color(red: 0.8, green: 0.78, blue: 0.75),  // Soft gray
                    Color(red: 0.7, green: 0.68, blue: 0.65)   // Darker neutral
                ]),
                startPoint: animateGradient ? .bottomTrailing : .topLeading,
                endPoint: animateGradient ? .topLeading : .bottomTrailing
            )
            .opacity(0.12)
            .blur(radius: 40)
            .ignoresSafeArea()

            // Floating abstract shapes
            ForEach(0..<5, id: \.self) { index in
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.08),
                                Color(red: 0.9, green: 0.85, blue: 0.8).opacity(0.12)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: CGFloat.random(in: 100...250),
                           height: CGFloat.random(in: 100...250))
                    .blur(radius: 50)
                    .offset(
                        x: animateParticles ? CGFloat.random(in: -100...100) : CGFloat.random(in: -50...50),
                        y: animateParticles ? CGFloat.random(in: -150...150) : CGFloat.random(in: -75...75)
                    )
                    .animation(
                        Animation.easeInOut(duration: Double.random(in: 8...12))
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.5),
                        value: animateParticles
                    )
            }
        }
        .onAppear {
            withAnimation(Animation.linear(duration: 10).repeatForever(autoreverses: true)) {
                animateGradient = true
            }
            withAnimation {
                animateParticles = true
            }
        }
    }
}

// MARK: - Audio Player Manager
class AudioPlayerManager: ObservableObject {
    @Published var isPlaying = false
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0

    private var audioPlayer: AVAudioPlayer?
    private var timer: Timer?

    init() {
        setupAudioSession()
    }

    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }

    func loadAudio(named fileName: String, withExtension ext: String = "mp3") {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: ext) else {
            print("Audio file not found")
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            duration = audioPlayer?.duration ?? 0
        } catch {
            print("Failed to load audio: \(error)")
        }
    }

    func play() {
        audioPlayer?.play()
        isPlaying = true
        startTimer()
    }

    func pause() {
        audioPlayer?.pause()
        isPlaying = false
        stopTimer()
    }

    func togglePlayPause() {
        if isPlaying {
            pause()
        } else {
            play()
        }
    }

    func seek(to time: TimeInterval) {
        audioPlayer?.currentTime = time
        currentTime = time
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.currentTime = self.audioPlayer?.currentTime ?? 0

            if self.currentTime >= self.duration && self.duration > 0 {
                self.isPlaying = false
                self.stopTimer()
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    deinit {
        stopTimer()
    }
}

// Custom pebble shape
struct PebbleShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height

        // Create an organic pebble shape using curves
        path.move(to: CGPoint(x: width * 0.5, y: 0))

        path.addCurve(
            to: CGPoint(x: width, y: height * 0.4),
            control1: CGPoint(x: width * 0.85, y: height * 0.05),
            control2: CGPoint(x: width, y: height * 0.2)
        )

        path.addCurve(
            to: CGPoint(x: width * 0.5, y: height),
            control1: CGPoint(x: width, y: height * 0.7),
            control2: CGPoint(x: width * 0.75, y: height)
        )

        path.addCurve(
            to: CGPoint(x: 0, y: height * 0.4),
            control1: CGPoint(x: width * 0.25, y: height),
            control2: CGPoint(x: 0, y: height * 0.7)
        )

        path.addCurve(
            to: CGPoint(x: width * 0.5, y: 0),
            control1: CGPoint(x: 0, y: height * 0.2),
            control2: CGPoint(x: width * 0.15, y: height * 0.05)
        )

        return path
    }
}

// Custom button style for play/pause button
struct PlayPauseButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

struct HomeView: View {
    @StateObject private var audioPlayer = AudioPlayerManager()
    @State private var rotation: Double = 0
    @State private var timerCancellable: AnyCancellable?

    var body: some View {
        NavigationView {
            ZStack {
                // Independent animated background - runs continuously
                AnimatedGradientBackground()

                VStack(spacing: 40) {
                    Text("Mindful Breathing")
                        .font(.largeTitle)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color(red: 0.9, green: 0.85, blue: 0.8))

                    // Audio time display
                    Text(formatTime(audioPlayer.currentTime))
                        .font(.title)
                        .fontWeight(.medium)
                        .foregroundStyle(Color(red: 0.85, green: 0.82, blue: 0.78))

                    // Continuously rotating pebble (independent of audio)
                    ZStack {
                        PebbleShape()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 0.95, green: 0.9, blue: 0.85).opacity(0.9),  // Light cream
                                        Color(red: 0.85, green: 0.82, blue: 0.78).opacity(0.7)  // Soft taupe
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 200, height: 240)
                            .rotationEffect(.degrees(rotation))
                            .shadow(color: .black.opacity(0.5), radius: 15, x: 0, y: 5)

                        // Play/Pause button (controls audio only)
                        Button(action: {
                            audioPlayer.togglePlayPause()
                        }) {
                            Image(systemName: audioPlayer.isPlaying ? "pause.fill" : "play.fill")
                                .font(.system(size: 50, weight: .bold))
                                .foregroundStyle(Color.black.opacity(0.7))
                                .shadow(color: Color(red: 0.9, green: 0.85, blue: 0.8).opacity(0.5), radius: 2, x: 0, y: 0)
                                .scaleEffect(audioPlayer.isPlaying ? 1.0 : 1.1)
                                .offset(x: audioPlayer.isPlaying ? 0 : 3)
                        }
                        .buttonStyle(PlayPauseButtonStyle())
                    }

                    // Status indicator
                    HStack(spacing: 8) {
                        Circle()
                            .fill(audioPlayer.isPlaying ? Color(red: 0.6, green: 0.9, blue: 0.6) : Color(red: 0.9, green: 0.6, blue: 0.6))
                            .frame(width: 10, height: 10)
                        Text(audioPlayer.isPlaying ? "Playing meditation" : "Paused")
                            .font(.caption)
                            .foregroundStyle(Color(red: 0.8, green: 0.78, blue: 0.75))
                    }

                    // Duration display
                    if audioPlayer.duration > 0 {
                        HStack {
                            Text(formatTime(audioPlayer.currentTime))
                            Spacer()
                            Text(formatTime(audioPlayer.duration))
                        }
                        .font(.caption2)
                        .foregroundStyle(Color(red: 0.7, green: 0.68, blue: 0.65))
                        .padding(.horizontal, 40)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .navigationTitle("Home")
            .onAppear {
                // Load audio file when view appears
                // audioPlayer.loadAudio(named: "meditation", withExtension: "mp3")

                // Start timer when view appears
                timerCancellable = Timer.publish(every: 0.016, on: .main, in: .common)
                    .autoconnect()
                    .sink { _ in
                        // Continuous rotation independent of audio playback
                        withAnimation(.linear(duration: 0.016)) {
                            rotation += 0.5
                        }
                    }
            }
            .onDisappear {
                // Stop timer when view disappears to prevent memory leak
                timerCancellable?.cancel()
                timerCancellable = nil
            }
        }
    }

    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

#Preview {
    HomeView()
}
