//
//  File.swift
//  Helicon
//
//  Created by Yuriy Nefedov on 13.03.2025.
//

import Foundation
import HeliconFoundation

public protocol DatabaseType: Identifiable, Codable, StandardStringConvertible {
    var firestoreId: String? { get }
    var id: String { get }
    static var endpoint: String { get }
}
