//
//  SwiftUIView.swift
//  Helicon
//
//  Created by Yuriy Nefedov on 31.01.2026.
//

import Foundation
import SwiftUI

public struct SensoryFeedbackRequest: Identifiable, Equatable {
    public let id = UUID().uuidString
    var feedback: SensoryFeedback
    
    public init(_ feedback: SensoryFeedback) {
        self.feedback = feedback
    }
    
    public static func ==(lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}

public class HapticsManager: ObservableObject {
    @Published var request = SensoryFeedbackRequest(.impact)
    
    public init() {}
    
    public func fire(_ feedback: SensoryFeedback = .impact) {
        self.request = .init(feedback)
    }
}
