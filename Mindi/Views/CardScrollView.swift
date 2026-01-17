//
//  ScrollView.swift
//  Mindi
//
//  Created by Riv Sal on 11/17/25.
//

import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct CardItem: Identifiable {
    var id: Int
    var title: String
    var description: String
    var audioFileName: String
    var gradientColors: [Color]
//    var imageUrl: String?
}

struct CardScrollView: View {
    let cards = [
        CardItem(id: 0, title: "Grounding Meditation", description: "5 min", audioFileName: "grounding-meditation.mp3", gradientColors: [Color(hex: "6E7963"), Color(hex: "4A5540")]),
        CardItem(id: 1, title: "Breathing Exercise", description: "5 min", audioFileName: "breathing-exercise.mp3", gradientColors: [Color(hex: "8B7355"), Color(hex: "D2691E")]),
        CardItem(id: 2, title: "Sleep Exercise", description: "55 min", audioFileName: "Guided_Meditation_for_Sleep.mp3", gradientColors: [Color(hex: "5A7D5F"), Color(hex: "3D5A40")])
    ]
    @State private var selectedCard: CardItem?
    @State private var showPlayer = false

    // Get current day of week (1 = Sunday, 2 = Monday, ..., 7 = Saturday)
    private var currentDayOfWeek: Int {
        Calendar.current.component(.weekday, from: Date())
    }

    // Helper function to determine if a day should be highlighted
    private func shouldHighlight(index: Int) -> Bool {
        // Map array index to weekday: S(0)=Sun(1), M(2)=Mon(2), T(3)=Tue(3), W(4)=Wed(4), T(5)=Thu(5), F(6)=Fri(6), S(1)=Sat(7)
        let weekdayMapping = [1, 7, 2, 3, 4, 5, 6] // S S M T W T F -> Sun Sat Mon Tue Wed Thu Fri
        return weekdayMapping[index] == currentDayOfWeek
    }

    var body: some View {
        VStack {
            HStack {
                Text("Good Morning, User")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 25)
                //                .padding(.vertical)
                HStack(spacing: 4) {
                    // S S M T W T F represents the days
                    ForEach(0..<7) { index in
                        let days = ["S", "S", "M", "T", "W", "T", "F"]
                        Text(days[index])
                            .fontWeight(shouldHighlight(index: index) ? .bold : .regular)
                            .underline(shouldHighlight(index: index))
                    }
                }
                .padding(.trailing, 25)
                // add slider funcationality to the date
            }
            ScrollView {
                LazyVStack {
                    ForEach(cards) { card in
                        RoundedRectangle(cornerRadius: 20.0)
                            .fill(.ultraThinMaterial)
                            .overlay(
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(card.title)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    Text(card.description)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                .padding(40)
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                            )
                            .onTapGesture {
                                selectedCard = card
                                showPlayer = true
                            }
                            .scaleEffect(selectedCard?.id == card.id && showPlayer ? 0.95 : 1.0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: showPlayer)
                    }
                    .containerRelativeFrame(.vertical)
                }
            }
        }
        .contentMargins(5)
        .background(
            RadialGradient(
                gradient: Gradient(colors: [
                    Color(hex: "6E7963"),
                    Color(hex: "000000")
                ]),
                center: .center,
                startRadius: 0,
                endRadius: 500
            )
        )
        .fullScreenCover(isPresented: $showPlayer) {
            if let card = selectedCard {
                ZStack(alignment: .topLeading) {
                    AudioPlayerView(card: card)

                    // Close button
                    Button(action: {
                        showPlayer = false
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Circle().fill(.white.opacity(0.3)))
                    }
                    .padding(20)
                }
            }
        }
    }
}

#Preview {
    CardScrollView()
}
