//
//  SwiftUIView.swift
//  Helicon
//
//  Created by Yuriy Nefedov on 01.02.2026.
//

import SwiftUI

public struct ProgressiveBlurView: View {
    
    public init() {}
    
    public var body: some View {
        
        Rectangle()
            .fill(.ultraThinMaterial)
            .mask {
                VStack(spacing: 0) {
                    LinearGradient(
                        colors: [
                            Color.black.opacity(0),
                            Color.black.opacity(1),
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    Rectangle()
                }
            }
        
    }
}

#Preview {
    ProgressiveBlurView()
}
