//
//  SafeAreaInsets.swift
//  iOS App
//
//  Created by Yuriy Nefedov on 06.12.2025.
//

// Source - https://stackoverflow.com/a/68709575
// Posted by Mirko, modified by community. See post 'Timeline' for change history
// Retrieved 2025-12-06, License - CC BY-SA 4.0

import SwiftUI

// Source - https://stackoverflow.com/a/68709575
// Posted by Mirko, modified by community. See post 'Timeline' for change history
// Retrieved 2025-12-06, License - CC BY-SA 4.0

@MainActor public extension UIApplication {
    public var keyWindow: UIWindow? {
        connectedScenes.lazy
            .compactMap { ($0 as? UIWindowScene)?.keyWindow }
            .first
    }
    
    public var currentUIWindow: UIWindow? {
        let connectedScenes = UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .compactMap { $0 as? UIWindowScene }
        
        let window = connectedScenes.first?
            .windows
            .first { $0.isKeyWindow }
        return window
    }
    
    public var rootViewController: UIViewController? {
        let connectedScenes = UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .compactMap { $0 as? UIWindowScene }
        let window = connectedScenes.first?.windows.first { $0.isKeyWindow }
        let rootViewController = window?.rootViewController
        return rootViewController
    }

    public func topViewController(of viewController: UIViewController? = nil) -> UIViewController? {
        
        let viewController: UIViewController? = viewController ?? rootViewController
        
        if let navigationController = viewController as? UINavigationController {
            return topViewController(of: navigationController.visibleViewController)
        }
        if let tabController = viewController as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(of: selected)
            }
        }
        if let presented = viewController?.presentedViewController {
            return topViewController(of: presented)
        }
        return viewController
    }
}
