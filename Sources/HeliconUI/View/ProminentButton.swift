//
//  File.swift
//  Helicon
//
//  Created by Yuriy Nefedov on 27.01.2026.
//

import Foundation
import SwiftUI


public struct ProminentButton: View {
    
    public enum Style {
        case primary, secondary
    }
    
    let title: String
    let systemImage: String?
    let action: () -> Void
    var style: Style
    
    private let height: CGFloat = 42
    
    public init(title: String, systemImage: String? = nil, style: Style = .primary, action: @escaping () -> Void) {
        self.title = title
        self.systemImage = systemImage
        self.action = action
        self.style = style
    }
    
    public var body: some View {
        switch style {
        case .primary:
            buttonBase
                .glassOrBorderedProminent()
        case .secondary:
            buttonBase
                .glassOrBordered()
        }
    }
    
    private var buttonBase: some View {
        Button {
            action()
        } label: {
            HStack {
                Spacer()
                if let systemImage {
                    Image(systemName: systemImage)
                }
                Text(title)
                Spacer()
            }
            .frame(height: self.height)
        }
    }
}
