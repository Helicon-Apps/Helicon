//
//  Parallax.swift
//
//  Created by Yuriy Nefedov on 05.12.2025.
//

import SwiftUI
import CoreMotion

public enum ParallaxDirection {
    case roll
    case pitchAndRoll
}

public struct MotionParallaxModifier: ViewModifier {
    @State private var pitchDegrees: Double = 0
    @State private var rollDegrees: Double = 0
    private let motionManager = CMMotionManager()
    private let maxTiltDegrees: Double
    private let updateHz: Double
    private let direction: ParallaxDirection

    public init(maxTiltDegrees: Double = 10, updateHz: Double = 60, direction: ParallaxDirection = .pitchAndRoll) {
        self.maxTiltDegrees = maxTiltDegrees
        self.updateHz = updateHz
        self.direction = direction
    }

    public func body(content: Content) -> some View {
        content
            .rotation3DEffect(.degrees(pitchDegrees), axis: (x: 1, y: 0, z: 0))
            .rotation3DEffect(.degrees(rollDegrees), axis: (x: 0, y: 1, z: 0))
            .animation(.easeOut(duration: 0.08), value: pitchDegrees)
            .animation(.easeOut(duration: 0.08), value: rollDegrees)
            .onAppear {
                
                if motionManager.isDeviceMotionAvailable {
                    
                    motionManager.deviceMotionUpdateInterval = 1.0 / updateHz
                    
                    motionManager.startDeviceMotionUpdates(
                        using: .xArbitraryCorrectedZVertical,
                        to: .main
                    ) { motion, error in
                        guard error == nil, let motion = motion else { return }
                        let pitch = motion.attitude.pitch * 180 / .pi
                        let roll = motion.attitude.roll * 180 / .pi

                        if direction == .roll {
                            pitchDegrees = 0
                            rollDegrees = -parallaxAngle(from: roll)
                        } else {
                            pitchDegrees = parallaxAngle(from: pitch)
                            rollDegrees = -parallaxAngle(from: roll)
                        }
                    }
                }
            }
            .onDisappear {
                motionManager.stopDeviceMotionUpdates()
            }
    }
    
    // Linear
    private func parallaxAngle(from gyroAngle: Double, maxGyroAngle: Double = 60, maxParallaxAngle: Double = 10) -> Double {
        let gyroAngle = min(gyroAngle, maxGyroAngle)
        return (maxParallaxAngle / maxGyroAngle) * gyroAngle
        
        // f(x) = a*x
        // f(maxGyroAngle) = maxParallaxAngle
        // a*maxGyroAngle = maxParallaxAngle
        // a = maxParallaxAngle / maxGyroAngle
        // f(x) = (maxParallaxAngle / maxGyroAngle) * x
    }
}

public struct GestureParallaxModifier: ViewModifier {
    @State private var pitchDegrees: Double = 0
    @State private var rollDegrees: Double = 0

    private let maxTiltDegrees: Double
    private let sensitivity: Double
    private let direction: ParallaxDirection

    public init(maxTiltDegrees: Double = 10, sensitivity: Double = 0.2, direction: ParallaxDirection = .pitchAndRoll) {
        self.maxTiltDegrees = maxTiltDegrees
        self.sensitivity = sensitivity
        self.direction = direction
    }

    public func body(content: Content) -> some View {
        let drag = DragGesture(minimumDistance: 0)
            .onChanged { value in
                // Convert drag translation into pitch (x-axis) and roll (y-axis) rotations.
                let dx = value.translation.width
                let dy = value.translation.height
                let computedPitch = max(-maxTiltDegrees, min(maxTiltDegrees, -dy * sensitivity))
                let computedRoll = max(-maxTiltDegrees, min(maxTiltDegrees, dx * sensitivity))
                switch direction {
                case .roll:
                    pitchDegrees = 0
                    rollDegrees = computedRoll
                case .pitchAndRoll:
                    pitchDegrees = computedPitch
                    rollDegrees = computedRoll
                }
            }
            .onEnded { _ in
                // Return smoothly to rest.
                pitchDegrees = 0
                rollDegrees = 0
            }

        return content
            .rotation3DEffect(.degrees(pitchDegrees), axis: (x: 1, y: 0, z: 0))
            .rotation3DEffect(.degrees(rollDegrees), axis: (x: 0, y: 1, z: 0))
            .animation(.easeOut(duration: 0.12), value: pitchDegrees)
            .animation(.easeOut(duration: 0.12), value: rollDegrees)
            .gesture(drag)
    }
}

public extension View {
    func gyroParallax(
        _ direction: ParallaxDirection = .roll,
        maxTiltDegrees: Double = 6,
        updateHz: Double = 120
    ) -> some View {
        self.modifier(
            MotionParallaxModifier(
                maxTiltDegrees: maxTiltDegrees,
                updateHz: updateHz,
                direction: direction
            )
        )
    }
    
    func gestureParallax(
        _ direction: ParallaxDirection = .pitchAndRoll,
        maxTiltDegrees: Double = 10,
        sensitivity: Double = 0.05
    ) -> some View {
        self.modifier(
            GestureParallaxModifier(
                maxTiltDegrees: maxTiltDegrees,
                sensitivity: sensitivity,
                direction: direction
            )
        )
    }
}

fileprivate struct Parallax: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 24)
            .foregroundStyle(Color.blue.opacity(0.66))
            .aspectRatio(1/1.5, contentMode: .fit)
            .frame(width: 200)
            .padding(100)
            .gestureParallax(.roll)
    }
}

#Preview {
    Parallax()
}
