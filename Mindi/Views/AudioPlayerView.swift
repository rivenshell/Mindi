//
//  AudioPlayerView.swift
//  Mindi
//
//  Expandable audio player with controls
//

import SwiftUI

struct AudioPlayerView: View {
    let card: CardItem
    @StateObject private var audioManager = AudioPlayerManager()
    private let storageService = SupabaseStorageService()
    @State private var errorMessage: String?

    var body: some View {
        ZStack {
            // Animated background
            FlowingMeshGradientView(colors: card.gradientColors)

            VStack(spacing: 40) {
                Spacer()

                // Title and description
                VStack(spacing: 12) {
                    Text(card.title)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)

                    Text(card.description)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(.horizontal)

                // Progress bar
                VStack(spacing: 8) {
                    Slider(
                        value: Binding(
                            get: { audioManager.currentTime },
                            set: { audioManager.seek(to: $0) }
                        ),
                        in: 0...max(audioManager.duration, 1)
                    )
                    .tint(.white)

                    HStack {
                        Text(formatTime(audioManager.currentTime))
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))

                        Spacer()

                        Text(formatTime(audioManager.duration))
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                .padding(.horizontal, 40)

                // Playback controls
                HStack(spacing: 60) {
                    // Rewind 15s
                    Button(action: {
                        let newTime = max(0, audioManager.currentTime - 15)
                        audioManager.seek(to: newTime)
                    }) {
                        Image(systemName: "gobackward.15")
                            .font(.system(size: 28))
                            .foregroundColor(.white)
                    }

                    // Play/Pause button
                    Button(action: {
                        audioManager.togglePlayPause()
                    }) {
                        ZStack {
                            Circle()
                                .fill(.white.opacity(0.3))
                                .frame(width: 80, height: 80)

                            Image(systemName: audioManager.isPlaying ? "pause.fill" : "play.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.white)
                                .offset(x: audioManager.isPlaying ? 0 : 3)
                        }
                    }
                    .disabled(audioManager.isLoading)

                    // Forward 15s
                    Button(action: {
                        let newTime = min(audioManager.duration, audioManager.currentTime + 15)
                        audioManager.seek(to: newTime)
                    }) {
                        Image(systemName: "goforward.15")
                            .font(.system(size: 28))
                            .foregroundColor(.white)
                    }
                }

                // Error message
                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                        .background(.white.opacity(0.2))
                        .cornerRadius(10)
                        .padding(.horizontal)
                }

                // Loading indicator
                if audioManager.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                }

                Spacer()
            }
        }
        .onAppear {
            loadAudio()
        }
    }

    private func loadAudio() {
        Task {
            do {
                let audioData = try await storageService.fetchAudio(fileName: card.audioFileName)
                await MainActor.run {
                    audioManager.loadAudio(from: audioData)
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Failed to load audio: \(error.localizedDescription)"
                }
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
    AudioPlayerView(card: CardItem(
        id: 0,
        title: "Grounding Meditation",
        description: "5 min",
        audioFileName: "grounding-meditation.mp3",
        gradientColors: [Color(hex: "6E7963"), Color(hex: "4A5540")]
    ))
}
