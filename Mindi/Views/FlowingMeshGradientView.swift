//
//  FlowingMeshGradientView.swift
//  Mindi
//
//  Animated mesh gradient background
//

import SwiftUI

struct FlowingMeshGradientView: View {
    let colors: [Color]
    @State private var animationOffset: CGFloat = 0
    @State private var secondaryOffset: CGFloat = 0

    var body: some View {
        ZStack {
            // Base gradient layer
            MeshGradient(colors: colors, offset: animationOffset)
                .ignoresSafeArea()

            // Overlay flowing gradient
            MeshGradient(colors: colors.reversed(), offset: secondaryOffset)
                .ignoresSafeArea()
                .opacity(0.6)
                .blendMode(.overlay)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 8).repeatForever(autoreverses: true)) {
                animationOffset = 1.0
            }
            withAnimation(.easeInOut(duration: 12).repeatForever(autoreverses: true)) {
                secondaryOffset = 1.0
            }
        }
    }
}

struct MeshGradient: View {
    let colors: [Color]
    let offset: CGFloat

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height

            Canvas { context, size in
                let centerX = size.width / 2
                let centerY = size.height / 2

                // Create flowing gradient effect
                for (index, color) in colors.enumerated() {
                    let angle = Double(index) * .pi * 2.0 / Double(colors.count) + Double(offset) * .pi
                    let radius = min(width, height) * (0.5 + offset * 0.3)

                    let x = centerX + cos(angle) * radius * (0.5 + offset * 0.5)
                    let y = centerY + sin(angle) * radius * (0.5 + offset * 0.5)

                    let gradient = Gradient(colors: [color, color.opacity(0.0)])
                    let radialGradient = RadialGradient(
                        gradient: gradient,
                        center: .init(x: x, y: y),
                        startRadius: 0,
                        endRadius: radius
                    )

                    context.fill(
                        Path(ellipseIn: CGRect(x: 0, y: 0, width: size.width, height: size.height)),
                        with: .linearGradient(
                            gradient,
                            startPoint: CGPoint(x: centerX, y: centerY),
                            endPoint: CGPoint(x: x, y: y)
                        )
                    )
                }
            }
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
