//
//  File.swift
//  Helicon
//
//  Created by Yuriy Nefedov on 27.01.2026.
//

import Foundation
import SwiftUI


public struct AppButton: View {
    
    let title: String
    let systemImage: String?
    let action: () -> Void
    var isProminent: Bool
    
    private let height: CGFloat = 42
    
    public init(title: String, systemImage: String? = nil, isProminent: Bool = true, action: @escaping () -> Void) {
        self.title = title
        self.systemImage = systemImage
        self.action = action
        self.isProminent = isProminent
    }
    
    public var body: some View {
        if isProminent {
            buttonBase
                .glassOrBorderedProminent()
        } else {
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
