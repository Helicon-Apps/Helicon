//
//  File.swift
//  Helicon
//
//  Created by Yuriy Nefedov on 27.01.2026.
//


import SwiftUI

public struct GlassOrBordered: ViewModifier {
    public func body(content: Content) -> some View {
        #if os(watchOS)
        if #available(watchOS 26.0, *) {
            content.buttonStyle(.glass)
        } else {
            content.buttonStyle(.bordered)
        }
        #elseif os(iOS)
        if #available(iOS 26.0, *) {
            content.buttonStyle(.glass)
        } else {
            content.buttonStyle(.bordered)
        }
        #endif
    }
}

public struct GlassOrBorderedProminent: ViewModifier {
    public func body(content: Content) -> some View {
        #if os(watchOS)
        if #available(watchOS 26.0, *) {
            content.buttonStyle(.glassProminent)
        } else {
            content.buttonStyle(.borderedProminent)
        }
        #elseif os(iOS)
        if #available(iOS 26.0, *) {
            content.buttonStyle(.glassProminent)
        } else {
            content.buttonStyle(.borderedProminent)
        }
        #endif
    }
}

public extension View {
    func glassOrBordered() -> some View {
        modifier(GlassOrBordered())
    }
}

public extension View {
    func glassOrBorderedProminent() -> some View {
        modifier(GlassOrBorderedProminent())
    }
}
