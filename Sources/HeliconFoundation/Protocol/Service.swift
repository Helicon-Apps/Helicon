//
//  File.swift
//  Helicon
//
//  Created by Yuriy Nefedov on 13.03.2025.
//

import Foundation

public protocol Service: ClassNameRepresentable {
    static var serviceName: String { get }
    
    func log(_ msg:String)
}

public extension Service {
    static var serviceName: String { Self.className }
    
    func log(_ msg:String) {
        let formatted = "[\(Self.serviceName)]: \(msg)"
        print(formatted)
        NSLog(formatted)
    }
}
