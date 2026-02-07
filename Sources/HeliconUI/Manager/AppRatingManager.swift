//
//  AppRatingManager.swift
//
//  Created by Yuriy Nefedov on 29.10.2022.
//

import Foundation
import StoreKit
import SwiftUI

@Observable
public class AppRatingManager {
    
    var disableInDebug: Bool = false
    var customPromptPresented: Bool = false
    
    public init() {}
    
    private func passDebugCondition() -> Bool {
        if disableInDebug {
            #if DEBUG
            return false
            #else
            return true
            #endif
        } else {
            return true
        }
    }
    
    private func passChanceCondition(_ chance: Double = 1.0) -> Bool {
        let randomNumber = Double.random(in: 0...1)
        return chance >= randomNumber
    }
    
    @MainActor
    public func systemRequestReviewIfAppropriate(chance: Double = 1.0) {
        guard passDebugCondition(), passChanceCondition(chance) else {
            return
        }
        
        if let scene = UIApplication.shared.connectedScenes.first(
            where: { $0.activationState == .foregroundActive }
        ) as? UIWindowScene {
            if #available(iOS 18, *) {
                AppStore.requestReview(in: scene)
            } else {
                SKStoreReviewController.requestReview(in: scene)
            }
        }
    }
    
    @MainActor
    public func showCustomPromptIfAppropriate(chance: Double = 1.0) {
        guard passDebugCondition(), passChanceCondition(chance) else {
            return
        }
 
        self.customPromptPresented = true
    }
    
    
}
