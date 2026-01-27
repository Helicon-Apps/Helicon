
import Foundation
import SwiftUI

public enum Opacity: CGFloat {
    case textProminent = 1
    case textQuiet = 0.85
}

public extension View {
    
    func opacity(_ value: Opacity) -> some View {
        self.opacity(value.rawValue)
    }
    
    /// Applies a prominent text opacity (fully opaque)
    func textProminentOpacity() -> some View {
        self.opacity(Opacity.textProminent)
    }
    /// Applies a quiet text opacity (slightly reduced opacity)
    func textQuietOpacity() -> some View {
        self.opacity(Opacity.textQuiet)
    }
}

