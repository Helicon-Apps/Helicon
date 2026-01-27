//
//  View+GlassCapsuleBackground.swift
//
//  Created by Yuriy Nefedov on 27.11.2025.
//

import Foundation
import SwiftUI

public extension View {
    func glassCapsuleBackground(
        _ glassType: GlassType? = nil,
        _ material: Material? = nil
    ) -> some View {
        modifier(
            GlassCapsuleBackground(
                glassType: glassType,
                material: material
            )
        )
    }
}

public struct GlassCapsuleBackground: ViewModifier {
    let glassType: GlassType?
    let material: Material?

    public func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            // If a glass effect is provided, use it. Otherwise default to `.clear`
            let glass: Glass = {
                switch glassType {
                case .regular: return .regular
                case .clear: return .clear
                default: return .regular
                }
            }()
            content.glassEffect(glass)
        } else {
            // Fallback: custom material if provided, else `.thinMaterial`
            content
                .background(material ?? .ultraThinMaterial)
                .clipShape(Capsule())
        }
    }
}

public enum GlassType: Sendable {
    case clear
    case regular
    
    public static let `default`: Self = .clear
}
