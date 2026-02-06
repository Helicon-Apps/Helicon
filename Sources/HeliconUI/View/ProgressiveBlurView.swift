//
//  SwiftUIView.swift
//  Helicon
//
//  Created by Yuriy Nefedov on 01.02.2026.
//

import SwiftUI

public struct ProgressiveBlurView: View {
    
    let startPoint: UnitPoint
    let endPoint: UnitPoint
    
    public init(startPoint: UnitPoint = .top, endPoint: UnitPoint = .bottom) {
        self.startPoint = startPoint
        self.endPoint = endPoint
    }
    
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
                        startPoint: startPoint,
                        endPoint: endPoint
                    )
                    Rectangle()
                }
            }
        
    }
}

#Preview {
    ProgressiveBlurView()
}
