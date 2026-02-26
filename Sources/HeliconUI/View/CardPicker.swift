//
//  CardPicker.swift
//  Helicon
//
//  Created by Yuriy Nefedov on 22.05.2025.
//

import SwiftUI
import HeliconFoundation

public struct CardPicker<Content: View, T: Identifiable & Equatable & TitleRepresentable>: View {
    @Binding var selection: T
    
    var direction: CardPickerStackDirection = .default
    let options: [T]
    
    var spacing: CGFloat
    var strokeWidth: CGFloat
    var innerPadding: CGFloat
    var cornerRadius: CGFloat
    var applyScaleEffect: Bool
    var applyOpacityEffect: Bool
    var font: Font
    var fontWeight: Font.Weight
    var selectedFontWeight: Font.Weight
    var labelPadding: CGFloat
    var hideLabels: Bool
    
    let content: (T) -> Content
    var onDoubleSelect: (() -> Void)?
    
    var innerCornerRadiusDecrement: CGFloat { innerPadding / 2 }
    
    public init(
        selection: Binding<T>,
        direction: CardPickerStackDirection,
        options: [T],
        spacing: CGFloat = 16,
        strokeWidth: CGFloat = 3,
        innerPadding: CGFloat = 6,
        cornerRadius: CGFloat = 20,
        applyScaleEffect: Bool = true,
        applyOpacityEffect: Bool = true,
        font: Font = .subheadline,
        fontWeight: Font.Weight = .medium,
        selectedFontWeight: Font.Weight = .medium,
        labelPadding: CGFloat = 12,
        hideLabels: Bool = false,
        content: @escaping (T) -> Content,
        onDoubleSelect: (() -> Void)? = nil
    ) {
        self._selection = selection
        self.direction = direction
        self.options = options
        self.spacing = spacing
        self.strokeWidth = strokeWidth
        self.innerPadding = innerPadding
        self.cornerRadius = cornerRadius
        self.applyScaleEffect = applyScaleEffect
        self.applyOpacityEffect = applyOpacityEffect
        self.font = font
        self.fontWeight = fontWeight
        self.selectedFontWeight = selectedFontWeight
        self.labelPadding = labelPadding
        self.hideLabels = hideLabels
        self.content = content
        self.onDoubleSelect = onDoubleSelect
    }
    
    public var body: some View {
        picker
    }
    
    @ViewBuilder
    private var picker: some View {
        switch direction {
        case .vertical:
            VStack(spacing: spacing) {
                pickerContent
            }
        case .horizontal:
            HStack(spacing: spacing) {
                pickerContent
            }
        }
    }
    
    private var pickerContent: some View {
        ForEach(options) { option in
            view(for: option)
                .buttonWrapped {
                    withAnimation {
                        if selection == option {
                            if let onDoubleSelect {
                                onDoubleSelect()
                            }
                        } else {
                            selection = option
                        }
                    }
                }
        }
    }
    
    @ViewBuilder
    private func view(for option: T) -> some View {
        VStack(spacing: labelPadding) {
            card(for: option)
            if !hideLabels {
                label(for: option)
            }
        }
    }
    
    @ViewBuilder
    private func card(for option: T) -> some View {
        let isSelected = selection == option
        let scaleEffect: CGFloat = isSelected ? 1.025 : 0.975
        let opacityEffect: CGFloat = isSelected ? 1 : 0.75
        
        ZStack {
            content(option)
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: cornerRadius - innerPadding/2
                    )
                )
                .padding(innerPadding)
                .background(
                    RoundedRectangle(
                        cornerRadius: cornerRadius
                    )
                    .stroke(
                        isSelected ? Color.accentColor : .clear,
                        lineWidth: strokeWidth
                    )
                    .padding(strokeWidth / 2)
                )
        }
        .scaleEffect(applyScaleEffect ? scaleEffect : 1)
        .opacity(applyOpacityEffect ? opacityEffect : 1)
    }
    
    @ViewBuilder
    private func label(for option: T) -> some View {
        let isSelected = selection == option
        
        Text(option.title)
            .font(font)
            .fontWeight(isSelected ? selectedFontWeight : fontWeight)
            .foregroundStyle(Color.primary)
    }
}


public enum CardPickerStackDirection: Sendable {
    case vertical
    case horizontal
    
    static let `default`: Self = .vertical
}

fileprivate enum Animal: String, Identifiable, Equatable, CaseIterable, TitleRepresentable {
    case dog
    case elephant
    case dinosaur
    
    var emoji: String {
        switch self {
        case .dog: "🐶"
        case .elephant: "🐘"
        case .dinosaur: "🦖"
        }
    }
    
    var title: String {
        rawValue.capitalized
    }
    
    var id: String { rawValue }
}

fileprivate struct AnimalPicker: View {
    @State private var animal: Animal = .elephant
    
    var body: some View {
        CardPicker(
            selection: $animal,
            direction: .vertical,
            options: Animal.allCases) { animal in
                ZStack {
                    Rectangle()
                        .foregroundStyle(.gray.opacity(0.1))
                    Text(animal.emoji)
                        .font(.largeTitle)
                }
                .frame(width: 100, height: 100)
            } onDoubleSelect: {
                print("Double selected \(animal)")
            }

    }
}

#Preview {
    AnimalPicker()
}
