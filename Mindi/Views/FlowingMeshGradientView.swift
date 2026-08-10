//
//  FlowingMeshGradientView.swift
//  Mindi
//
//  Animated gradient background with soft blurred shapes
//

import SwiftUI

struct FlowingMeshGradientView: View {
    let colors: [Color]

    var body: some View {
        ZStack {
            // Base dark gradient
            LinearGradient(
                gradient: Gradient(colors: [colors[0].opacity(0.8), Color.black]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Animated blurred shapes
            AnimatedBlurredShape(color: colors[0], delay: 0)
            AnimatedBlurredShape(color: colors.count > 1 ? colors[1] : colors[0], delay: 2)
            AnimatedBlurredShape(color: colors[0].opacity(0.7), delay: 4)
            if colors.count > 1 {
                AnimatedBlurredShape(color: colors[1].opacity(0.6), delay: 6)
            }
        }
    }
}

struct AnimatedBlurredShape: View {
    let color: Color
    let delay: Double

    @State private var position: CGPoint = .zero
    @State private var scale: CGFloat = 1.0

    var body: some View {
        GeometryReader { geometry in
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [color, color.opacity(0.3)]),
                        center: .center,
                        startRadius: 0,
                        endRadius: 150
                    )
                )
                .frame(width: 300, height: 300)
                .blur(radius: 60)
                .opacity(0.6)
                .scaleEffect(scale)
                .position(position)
                .onAppear {
                    // Set initial random position
                    position = CGPoint(
                        x: geometry.size.width * 0.3,
                        y: geometry.size.height * 0.3
                    )

                    // Start animation after delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                        animateShape(in: geometry.size)
                    }
                }
        }
        .ignoresSafeArea()
    }

    private func animateShape(in size: CGSize) {
        withAnimation(
            .easeInOut(duration: 8 + Double.random(in: -2...2))
            .repeatForever(autoreverses: true)
        ) {
            position = CGPoint(
                x: size.width * CGFloat.random(in: 0.2...0.8),
                y: size.height * CGFloat.random(in: 0.2...0.8)
            )
        }

        withAnimation(
            .easeInOut(duration: 6 + Double.random(in: -1...1))
            .repeatForever(autoreverses: true)
        ) {
            scale = CGFloat.random(in: 0.8...1.4)
        }
    }
}

#Preview {
    FlowingMeshGradientView(colors: [
        Color(hex: "6E7963"),
        Color(hex: "4A5540"),
        Color(hex: "8B7355")
    ])
}
