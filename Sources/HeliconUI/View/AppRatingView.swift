//
//  AppRatingView.swift
//  Helicon
//
//  Created by Yuriy Nefedov on 05.02.2026.
//

import SwiftUI

public struct AppRatingView: View {
    let title: String
    let caption: String
    let onRateNow: () -> Void
    let onMaybeLater: () -> Void
    let backgroundColor: Color
    
    public init(appName: String, backgroundColor: Color, onRateNow: @escaping () -> Void = {}, onMaybeLater: @escaping () -> Void = {}) {
        
        self.title = "Help us grow ❤️"
        self.caption = "We just launched \(appName). Help more people find us with a quick rating."
        self.onRateNow = onRateNow
        self.onMaybeLater = onMaybeLater
        self.backgroundColor = backgroundColor
    }
    
    public init(title: String, caption: String, backgroundColor: Color, onRateNow: @escaping () -> Void = {}, onMaybeLater: @escaping () -> Void = {}) {
        
        self.title = title
        self.caption = caption
        self.onRateNow = onRateNow
        self.onMaybeLater = onMaybeLater
        self.backgroundColor = backgroundColor
        
    }

    public var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Title
                Text(title)
                    .font(.title.bold())
                    .multilineTextAlignment(.center)

                // Message
                Text(caption)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

    //            Text("Your support means the world to our tiny team ❤️")
    //                .font(.callout)
    //                .foregroundStyle(.secondary)
    //                .multilineTextAlignment(.center)

                // Actions
                VStack(spacing: 12) {
                    AppButton(
                        title: "Rate us",
                        action: onRateNow
                    )
                    .frame(maxWidth: .infinity)

                    AppButton(
                        title: "Maybe later",
                        isProminent: false,
                        action: onMaybeLater
                    )
                    .frame(maxWidth: .infinity)
                }
                .padding(.top, 8)
            }
            .padding(24)
        }
    }
}

// MARK: - Preview
private struct AppRatingPreviewHost: View {
    @State private var showSheet = true

    var body: some View {
        Color.clear
            .ignoresSafeArea()
            .sheet(isPresented: $showSheet) {
                AppRatingView(
                    appName: "Helicon",
                    backgroundColor: .black,
                    onRateNow: {
                        // Simulate rating action in preview
                        showSheet = false
                    }, onMaybeLater: {
                        showSheet = false
                    }
                )
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
            }
            .onAppear {
                // Present the sheet automatically in preview
                showSheet = true
            }
    }
}

#Preview("Bottom Sheet") {
    AppRatingPreviewHost()
}

