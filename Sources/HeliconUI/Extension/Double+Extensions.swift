//
//  Double+DecimalRounding.swift
//
//  Created by Yuriy Nefedov on 30.10.2025.
//

import Foundation

public extension Double {
    public func rounded(toDecimalPlaces decimalPlaces: Int) -> Self {
        let multiplier = pow(10.0, Double(decimalPlaces))
        return (self * multiplier).rounded() / multiplier
    }
}
