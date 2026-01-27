//
//  Stack+GradualAppear.swift
//  Helicon
//
//  Created by Yuriy Nefedov on 27.01.2026.
//

import SwiftUI
/// Delays the appearance of a view by fading it in after a specified interval.
private struct DelayAppearanceModifier: ViewModifier {
    let delay: TimeInterval
    let animation: Animation

    @State private var isVisible = false

    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .onAppear {
                // Start hidden, then reveal after the delay with the provided animation.
                isVisible = false
                withAnimation(animation.delay(delay)) {
                    isVisible = true
                }
            }
    }
}

public extension View {
    /// Fades in the view after the specified delay using the given animation.
    /// - Parameters:
    ///   - delay: The time to wait before starting the fade-in.
    ///   - animation: The animation to use for the fade-in. Defaults to `.easeInOut(duration: 0.3)`.
    /// - Returns: A view that appears after the delay.
    func delayAppearance(_ delay: TimeInterval, animation: Animation = .easeInOut(duration: 0.3)) -> some View {
        modifier(DelayAppearanceModifier(delay: delay, animation: animation))
    }
}

#Preview("delayAppearance") {
    VStack(spacing: 16) {
        Text("Appears immediately")
            .delayAppearance(
                0.2,
                animation: .easeIn(duration: 0.5)
            )
        Text("Appears after 1s")
            .delayAppearance(
                0.4,
                animation: .easeIn(duration: 0.5)
            )
        Text("Appears after 2s")
            .delayAppearance(
                0.6,
                animation: .easeIn(duration: 0.5)
            )
    }
    .padding()
}

