//
//  File.swift
//  Helicon
//
//  Created by Yuriy Nefedov on 27.01.2026.
//

import Foundation
import SwiftUI


public struct ProminentButton: View {
    
    let title: String
    let systemImage: String?
    let style: Style
    let disabled: Bool
    
    let action: () -> Void
    
    init(
        _ title: String,
        systemImage: String? = nil,
        style: Style = .default,
        disabled: Bool = false,
        action: @escaping () -> Void
    ) {
        
        self.title = title
        self.systemImage = systemImage
        self.style = style
        self.disabled = disabled
        self.action = action
        
    }
    
    public var body: some View {
        Button {
            action()
        } label: {
            ZStack {
                background
                HStack {
                    Spacer()
                    if let systemImage {
                        Image(systemName: systemImage)
                    }
                    Text(title)
                        .font(style.font)
                        .lineLimit(1)
                    Spacer()
                }
                .foregroundStyle(style.foregroundColor)
            }
            .frame(height: style.height)
        }
        .disabled(disabled)
        .opacity(disabled ? 0.5 : 1)
    }
    
    @ViewBuilder
    private var background: some View {
        if #available(iOS 26.0, *) {
            switch style {
            case .primary:
                Capsule()
                    .fill(Color.accentColor)
            case .secondary:
                ZStack {
                    Capsule()
                        .fill(.ultraThinMaterial)
                    Capsule()
                        .stroke(
                            Color.primary.opacity(0.12),
                            lineWidth: 1
                        )
                }
            case .glassPrimary:
                Capsule()
                    .fill(Color.accentColor.opacity(0.8))
                    .glassEffect(.regular)
            case .glassSecondary:
                Capsule()
                    .fill(Color.white.opacity(0.5))
                    .glassEffect(.regular)
            }
        } else {
            switch style {
            case .primary, .glassPrimary:
                Capsule()
                    .fill(Color.accentColor)
            case .secondary, .glassSecondary:
                ZStack {
                    Capsule()
                        .fill(.ultraThinMaterial)
                    Capsule()
                        .stroke(
                            Color.primary.opacity(0.12),
                            lineWidth: 1
                        )
                }
            }
        }
    }
    
    public enum Style: CaseIterable {
        case primary
        case secondary
        
        @available(iOS 26.0, *)
        case glassPrimary
        @available(iOS 26.0, *)
        case glassSecondary
        
        public static var allCases: [Style] {
            if #available(iOS 26.0, *) {
                return [.primary, .secondary, .glassPrimary, .glassSecondary]
            } else {
                return [.primary, .secondary]
            }
        }
        
        static var `default`: Self {
            if #available(iOS 26.0, *) {
                return .glassPrimary
            } else {
                return .primary
            }
        }
        
        var foregroundColor: Color {
            if #available(iOS 26.0, *) {
                switch self {
                case .primary:
                    return .white
                case .secondary:
                    return .primary
                case .glassPrimary:
                    return .white
                case .glassSecondary:
                    return .black
                }
            } else {
                switch self {
                case .primary, .glassPrimary:
                    return .white
                case .secondary, .glassSecondary:
                    return .primary
                }
            }
        }
        
        var font: Font {
            .body.weight(.medium)
        }
        
        var height: CGFloat {
            48
        }
    }
}
