//
//  AppRatingManager.swift
//
//  Created by Yuriy Nefedov on 29.10.2022.
//

import Foundation
import StoreKit

public struct AppRatingManager: Sendable {
    
    public static let shared = AppRatingManager()
    
    private init() {}
    
    @MainActor
    public func requestReviewIfAppropriate(chance: Double = 1.0) {
        #if !DEBUG
        let randomNumber = Double.random(in: 0...1)
        guard chance >= randomNumber else { return }
        
        if let scene = UIApplication.shared.connectedScenes.first(
            where: { $0.activationState == .foregroundActive }
        ) as? UIWindowScene {
            if #available(iOS 18, *) {
                AppStore.requestReview(in: scene)
            } else {
                SKStoreReviewController.requestReview(in: scene)
            }
        }
        #endif
    }
}
