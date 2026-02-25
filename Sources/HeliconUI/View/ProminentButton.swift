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
    
    public init(
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
        switch style {
        case .primary:
            if #available(iOS 26.0, *) {
                Capsule()
                    .fill(Color.accentColor.opacity(0.8))
                    .glassEffect(.regular)
            } else {
                Capsule()
                    .fill(Color.accentColor)
            }
        case .secondary:
            if #available(iOS 26.0, *) {
                Capsule()
                    .fill(Color.white.opacity(0.5))
                    .glassEffect(.regular)
            } else {
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
    
    public enum Style: CaseIterable, Sendable {
        case primary
        case secondary

        public static let `default`: Self = .primary
        
        var foregroundColor: Color {
            switch self {
            case .primary:
                return .white
            case .secondary:
                if #available(iOS 26.0, *) {
                    return .black
                } else {
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

#Preview("All Styles") {
    VStack(spacing: 12) {
        ForEach(ProminentButton.Style.allCases.indices, id: \.self) { index in
            let style = ProminentButton.Style.allCases[index]
            ProminentButton(
                String(describing: style).capitalized,
                systemImage: "star.fill",
                style: style
            ) {}
        }
    }
    .padding()
}
