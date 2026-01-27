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
    var systemImage: String? = nil
    let action: () -> Void
    
    private let height: CGFloat = 42
    
    public var body: some View {
        buttonBase
            .glassOrBorderedProminent()
    }
    
    private var buttonBase: some View {
        Button {
            action()
        } label: {
            HStack {
                Spacer()
                if let systemImage {
                    Image(systemName: systemImage)
                    Text(title)
                }
                Spacer()
            }
            .frame(height: self.height)
        }
    }
}
