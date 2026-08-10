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
            // Animated background - full screen
            FlowingMeshGradientView(colors: card.gradientColors)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // Title and description
                VStack(alignment: .leading, spacing: 8) {
                    Text(card.title)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)

                    Text(card.description)
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.white.opacity(0.7))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.bottom, 32)

                // Progress scrubber
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
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white.opacity(0.6))

                        Spacer()

                        Text(formatTime(audioManager.duration))
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
                .padding(.horizontal, 24)

                // Compact Spotify-style controls
                HStack(spacing: 40) {
                    Button {
                        audioManager.seek(to: max(0, audioManager.currentTime - 15))
                    } label: {
                        Image(systemName: "gobackward.15")
                            .font(.system(size: 28))
                            .foregroundColor(.white)
                    }

                    Button {
                        audioManager.togglePlayPause()
                    } label: {
                        Image(systemName: audioManager.isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.black)
                            .offset(x: audioManager.isPlaying ? 0 : 2)
                            .frame(width: 64, height: 64)
                            .background(Circle().fill(.white))
                    }
                    .disabled(audioManager.isLoading)

                    Button {
                        audioManager.seek(to: min(audioManager.duration, audioManager.currentTime + 15))
                    } label: {
                        Image(systemName: "goforward.15")
                            .font(.system(size: 28))
                            .foregroundColor(.white)
                    }
                }
                .padding(.top, 20)
                .padding(.bottom, 48)

                // Error message
                if let error = errorMessage {
                    Text(error)
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                        .padding()
                        .background(.red.opacity(0.6))
                        .cornerRadius(12)
                        .padding(.horizontal, 40)
                        .padding(.bottom, 20)
                }

                // Loading indicator
                if audioManager.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .padding(.bottom, 20)
                }
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
