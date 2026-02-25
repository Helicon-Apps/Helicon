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
    let backgroundColor: Color?
    
    public init(appName: String, backgroundColor: Color? = nil, onRateNow: @escaping () -> Void = {}, onMaybeLater: @escaping () -> Void = {}) {
        
        self.title = "Help us grow ❤️"
        self.caption = "We just launched \(appName). Help more people find us with a quick rating."
        self.onRateNow = onRateNow
        self.onMaybeLater = onMaybeLater
        self.backgroundColor = backgroundColor
    }
    
    public init(title: String, caption: String, backgroundColor: Color? = nil, onRateNow: @escaping () -> Void = {}, onMaybeLater: @escaping () -> Void = {}) {
        
        self.title = title
        self.caption = caption
        self.onRateNow = onRateNow
        self.onMaybeLater = onMaybeLater
        self.backgroundColor = backgroundColor
        
    }

    public var body: some View {
        ZStack {
            if let backgroundColor {
                backgroundColor.ignoresSafeArea()
            }
            
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
                    ProminentButton(
                        "Rate us",
                        action: onRateNow
                    )
                    .frame(maxWidth: .infinity)
                    .fontWeight(.semibold)

                    ProminentButton(
                        "Maybe later",
                        style: .secondary,
                        action: onMaybeLater
                    )
                    .frame(maxWidth: .infinity)
                }
                .padding(.top, 8)
            }
            .padding(24)
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}

public extension View {
    /// Presents the AppRatingView as a sheet using an app name to generate default copy.
    func appRatingSheet(
        isPresented: Binding<Bool>,
        appName: String,
        backgroundColor: Color? = nil,
        disabled: Bool = false,
        onRateNow: @escaping () -> Void = {},
        onMaybeLater: @escaping () -> Void = {}
    ) -> some View {
        let effectivePresented = Binding<Bool>(
            get: { !disabled && isPresented.wrappedValue },
            set: { newValue in isPresented.wrappedValue = newValue }
        )
        return sheet(isPresented: effectivePresented) {
            AppRatingView(
                appName: appName,
                backgroundColor: backgroundColor,
                onRateNow: {
                    onRateNow()
                    isPresented.wrappedValue = false
                },
                onMaybeLater: {
                    onMaybeLater()
                    isPresented.wrappedValue = false
                }
            )
        }
    }

    /// Presents the AppRatingView as a sheet with fully custom title and caption.
    func appRatingSheet(
        isPresented: Binding<Bool>,
        title: String,
        caption: String,
        backgroundColor: Color? = nil,
        disabled: Bool = false,
        onRateNow: @escaping () -> Void = {},
        onMaybeLater: @escaping () -> Void = {}
    ) -> some View {
        let effectivePresented = Binding<Bool>(
            get: { !disabled && isPresented.wrappedValue },
            set: { newValue in isPresented.wrappedValue = newValue }
        )
        return sheet(isPresented: effectivePresented) {
            AppRatingView(
                title: title,
                caption: caption,
                backgroundColor: backgroundColor,
                onRateNow: {
                    onRateNow()
                    isPresented.wrappedValue = false
                },
                onMaybeLater: {
                    onMaybeLater()
                    isPresented.wrappedValue = false
                }
            )
        }
    }
}

// MARK: - Preview
private struct AppRatingPreviewHost: View {
    @State private var showSheet = false

    var body: some View {
        Color.clear
            .ignoresSafeArea()
            .appRatingSheet(
                isPresented: $showSheet,
                appName: "Helicon",
//                backgroundColor: .black,
                disabled: false,
                onRateNow: {
                    // Simulate rating action in preview
                    showSheet = false
                },
                onMaybeLater: {
                    showSheet = false
                }
            )
            .onAppear {
                // Present the sheet automatically in preview
                DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                    showSheet = true
                }
            }
    }
}

#Preview("Bottom Sheet") {
    AppRatingPreviewHost()
}

