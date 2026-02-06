//
//  SmoothScrollView.swift
//
//  Created by Yuriy Nefedov on 17.07.2023.
//

import SwiftUI

public struct SmoothScrollView: View {
    var marginHeight: CGFloat
    var baseColor: Color
    var edges: Edge.Set
    var content: () -> any View
    
    init(
        marginHeight: CGFloat = 25,
        baseColor: Color = .white,
        edges: Edge.Set = [.top, .bottom],
        content: @escaping () -> any View
    ) {
        
        self.marginHeight = marginHeight
        self.baseColor = baseColor
        self.edges = edges
        self.content = content
        
    }
    
    public var body: some View {
        ZStack {
            ScrollView(.vertical, showsIndicators: false) {
                AnyView(content())
                    .padding(edges, marginHeight)
            }
            VStack {
                
                if edges.contains(.top) {
                    ProgressiveBlurView()
                        .rotationEffect(.degrees(180))
                    .frame(height: marginHeight)
                }
                
                Spacer()
                
                if edges.contains(.bottom) {
                    ProgressiveBlurView(
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: marginHeight)
                }
            }
        }
    }
}

#Preview {
    SmoothScrollView {
        Color.indigo
            .frame(height: 2000)
    }
    .padding()
}
