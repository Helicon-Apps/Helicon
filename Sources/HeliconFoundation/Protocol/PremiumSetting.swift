//
//  PremiumSetting.swift
//
//  Created by Yuriy Nefedov on 14.11.2025.
//

import Foundation

public protocol PremiumSetting: CaseIterable {
    var isPremium: Bool { get }
}

public extension PremiumSetting {
    
    static var premiumCases: [Self] {
        Self.allCases.filter({ $0.isPremium })
    }
    
    static var nonPremiumCases: [Self] {
        Self.allCases.filter({ $0.isPremium == false })
    }
    
    static var firstNonPremiumCase: Self {
        return Self.nonPremiumCases.first ?? .allCases.first!
    }
}
