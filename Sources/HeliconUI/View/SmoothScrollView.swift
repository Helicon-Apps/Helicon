//
//  SmoothScrollView.swift
//
//  Created by Yuriy Nefedov on 17.07.2023.
//

import SwiftUI

public struct SmoothScrollView: View {
    
    public enum Mode {
        case color(Color)
        case blur
        case blend
    }
    
    let marginHeight: CGFloat
    let applyPadding: Bool
    let mode: Mode
    let content: () -> any View
    
    public init(
        mode: Mode = .blur,
        marginHeight: CGFloat = 50,
        applyPadding: Bool = true,
        content: @escaping () -> any View
    ) {
        
        self.marginHeight = marginHeight
        self.applyPadding = applyPadding
        self.mode = mode
        self.content = content
        
    }
    
    public var body: some View {
        ZStack {
            Group {
                switch mode {
                case .blend:
                    scrollViewContent
                        .compositingGroup()
                        .mask(seethroughMask)
                default:
                    scrollViewContent
                }
            }
            Group {
                switch mode {
                case .blur, .color:
                    VStack {
                        marginOverlay(isTop: true)
                        Spacer()
                        marginOverlay(isTop: false)
                    }
                default:
                    EmptyView()
                }
            }
        }
    }
    
    private var scrollViewContent: some View {
        ScrollView(.vertical, showsIndicators: false) {
            AnyView(content())
                .padding(.vertical, applyPadding ? marginHeight : 0)
        }
    }
    
    private func marginOverlay(isTop: Bool) -> some View {
        Group {
            switch mode {
            case .blur:
                ProgressiveBlurView()
                    .rotationEffect(isTop ? .degrees(180) : .zero)
                    .frame(height: marginHeight)
            case .color(let c):
                LinearGradient(
                    colors: [c, c.opacity(0)],
                    startPoint: isTop ? .top : .bottom,
                    endPoint: isTop ? .bottom : .top
                )
                .frame(height: marginHeight)
            default:
                EmptyView()
            }
        }
    }
    
    private var seethroughMask: some View {
        VStack(spacing: 0) {
            LinearGradient(colors: [Color.white.opacity(0), Color.white], startPoint: .top, endPoint: .bottom)
                .frame(height: marginHeight)
            Rectangle()
                .fill(Color.white)
            LinearGradient(colors: [Color.white, Color.white.opacity(0)], startPoint: .top, endPoint: .bottom)
                .frame(height: marginHeight)
        }
    }
}

#Preview {
    ZStack {
//        Color.red.ignoresSafeArea()
        SmoothScrollView(
            mode: .blend,
            marginHeight: 200,
            applyPadding: true
        ) {
//            Color.indigo
//                .frame(height: 2000)
            ForEach(0...30, id: \.self) { index in
                
                let fontSize: CGFloat = .init(50 - index)
                
                Text("Hello, world")
                    .font(.system(size: fontSize))
            }
        }
//        .ignoresSafeArea()
    }
}

