//
//  OnboardingQuizView.swift
//
//  Created by Yuriy Nefedov on 09.11.2025.
//

import SwiftUI
import HeliconFoundation

public struct OnboardingQuizQuestion<T: Identifiable & Equatable & TitleRepresentable> {
    public let title: String
    public var description: String?
    public let options: [T]

    public init(
        title: String,
        description: String? = nil,
        options: [T]
    ) {
        self.title = title
        self.description = description
        self.options = options
    }
}

public struct OnboardingQuizHint {
    public let text: String
    public var systemImage: String? = "lightbulb.max.fill"
    public var lineLimit: Int = 1

    public init(
        text: String,
        systemImage: String? = "lightbulb.max.fill",
        lineLimit: Int = 1
    ) {
        self.text = text
        self.systemImage = systemImage
        self.lineLimit = lineLimit
    }
}

fileprivate extension CGFloat {
    static let onboardingTopSpacerHeight: Self = 32
}

public struct OnboardingQuizView<T: Identifiable & Equatable & TitleRepresentable>: View {

    private enum SelectionMode {
        case single(
            selection: Binding<T>,
            onSelectionChange: ((T) -> Void)?,
            completion: (() -> Void)?
        )
        case multiple(
            selection: Binding<[T]>,
            onSelectionChange: (([T]) -> Void)?,
            completion: (() -> Void)?
        )
    }

    let backgroundColor: Color?
    let question: OnboardingQuizQuestion<T>
    let showSkipButton: Bool
    var hint: OnboardingQuizHint? = nil
    var preContinueAction: (@escaping () -> Void) -> ()
    private let selectionMode: SelectionMode

    public init(
        backgroundColor: Color? = nil,
        question: OnboardingQuizQuestion<T>,
        selection: Binding<T>,
        showSkipButton: Bool = false,
        hint: OnboardingQuizHint? = nil,
        preContinueAction: @escaping (@escaping () -> Void) -> (),
        onSelectionChange: ((T) -> Void)? = nil,
        completion: (() -> Void)? = nil
    ) {
        self.backgroundColor = backgroundColor
        self.question = question
        self.showSkipButton = showSkipButton
        self.hint = hint
        self.preContinueAction = preContinueAction
        self.selectionMode = .single(
            selection: selection,
            onSelectionChange: onSelectionChange,
            completion: completion
        )
    }

    public init(
        backgroundColor: Color? = nil,
        question: OnboardingQuizQuestion<T>,
        selection: Binding<[T]>,
        showSkipButton: Bool = false,
        hint: OnboardingQuizHint? = nil,
        preContinueAction: @escaping (@escaping () -> Void) -> (),
        onSelectionChange: (([T]) -> Void)? = nil,
        completion: (() -> Void)? = nil
    ) {
        self.backgroundColor = backgroundColor
        self.question = question
        self.showSkipButton = showSkipButton
        self.hint = hint
        self.preContinueAction = preContinueAction
        self.selectionMode = .multiple(
            selection: selection,
            onSelectionChange: onSelectionChange,
            completion: completion
        )
    }

    public var body: some View {
        ZStack(alignment: .center) {

            if let backgroundColor {
                backgroundColor
                    .ignoresSafeArea()
            }
            ScrollView {
                VStack(spacing: 0) {
                    Spacer().frame(height: .onboardingTopSpacerHeight)
                    VStack(alignment: .leading, spacing: 24) {
                        header
                        picker
                    }
                    Spacer().frame(height: 220)
                }
                .padding(.horizontal)
            }
            .scrollIndicators(.hidden)

            actionLayer
        }
        .toolbar(.hidden)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 24) {

            Text(question.title)
                .font(.largeTitle.bold())
                .frame(maxWidth: .infinity, alignment: .leading)
            if let description = question.description {
                Text(description)
                    .opacity(Opacity.textQuiet)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

        }
        .font(.title3)
    }

    @ViewBuilder
    private var picker: some View {
        switch selectionMode {
        case .single:
            singlePicker
        case .multiple:
            multiplePicker
        }
    }

    private var singlePicker: some View {
        CardPicker(
            selection: singleSelectionBinding,
            direction: .vertical,
            options: question.options,
            hideLabels: true
        ) { option in
            quizOptionContent(for: option)
        } onDoubleSelect: {
            proceed()
        }
    }

    private var multiplePicker: some View {
        VStack(spacing: 16) {
            ForEach(question.options) { option in
                multipleOptionCard(for: option)
                    .buttonWrapped {
                        withAnimation {
                            toggleMultipleSelection(for: option)
                        }
                    }
            }
        }
    }

    private func multipleOptionCard(for option: T) -> some View {
        let isSelected = selectedMultipleOptions.contains(option)
        let scaleEffect: CGFloat = isSelected ? 1.025 : 0.975
        let opacityEffect: CGFloat = isSelected ? 1 : 0.75

        return ZStack {
            quizOptionContent(for: option)
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: 20 - 6 / 2
                    )
                )
                .padding(6)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            isSelected ? Color.accentColor : .clear,
                            lineWidth: 3
                        )
                        .padding(1.5)
                )
        }
        .scaleEffect(scaleEffect)
        .opacity(opacityEffect)
    }

    private func quizOptionContent(for option: T) -> some View {
        ZStack {
            Color.secondary.opacity(0.24)
            HStack {
                Spacer()
                Text(option.title)
                    .foregroundStyle(Color.primary)
                    .fontWeight(.semibold)
                Spacer()
            }
        }
        .frame(height: 56)
    }

    @ViewBuilder
    private var continueButton: some View {
        continueButtonBase
            .glassOrBorderedProminent()
            .opacityDisabled(!canProceed)
    }

    private var continueButtonBase: some View {
        Button {
            proceed()
        } label: {
            HStack {
                Spacer()
                Text("Continue")
                Spacer()
            }
            .frame(height: 42)
        }
    }

    @ViewBuilder
    private var skipButton: some View {
        skipButtonBase
            .glassOrBordered()
    }

    private var skipButtonBase: some View {
        Button {
            proceed()
        } label: {
            HStack {
                Spacer()
                Text("I'm not sure")
                Spacer()
            }
            .frame(height: 42)
        }
    }

    private var actionLayer: some View {
        VStack {
            Spacer()
            VStack(spacing: 8) {
                if let hint {
                    hintView(hint)
                }
                if showSkipButton {
                    skipButton
                }
                continueButton
            }
            .padding()
            .padding(.top)
            .background(
                progressiveBlurView
                    .ignoresSafeArea()
            )
        }
    }

    private func hintView(_ hint: OnboardingQuizHint) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Spacer()
            }
            .frame(height: 0)
            HStack {
                if let image = hint.systemImage {
                    Image(systemName: image)
                }
                Text(hint.text)
                    .lineLimit(hint.lineLimit)
            }
        }
        .font(.callout)
        .foregroundStyle(Color.secondary)
        .padding(.horizontal, 5)
        .padding(10)
        .glassCapsuleBackground()
    }

    private var progressiveBlurView: some View {
        Rectangle()
            .fill(.ultraThinMaterial)
            .mask {
                VStack(spacing: 0) {
                    LinearGradient(
                        colors: [
                            Color.black.opacity(1),
                            Color.black.opacity(0),
                        ],
                        startPoint: .bottom,
                        endPoint: .top
                    )
                    Rectangle()
                }
            }
    }

    private var singleSelectionBinding: Binding<T> {
        switch selectionMode {
        case let .single(selection, onSelectionChange, _):
            return Binding {
                selection.wrappedValue
            } set: { newValue in
                selection.wrappedValue = newValue
                onSelectionChange?(newValue)
            }
        case .multiple:
            fatalError("Attempted to read single selection binding in multiple mode.")
        }
    }

    private var selectedMultipleOptions: [T] {
        switch selectionMode {
        case let .multiple(selection, _, _):
            return selection.wrappedValue
        case .single:
            return []
        }
    }

    private var canProceed: Bool {
        switch selectionMode {
        case .single:
            return true
        case .multiple:
            return !selectedMultipleOptions.isEmpty
        }
    }

    private func toggleMultipleSelection(for option: T) {
        guard case let .multiple(selection, onSelectionChange, _) = selectionMode else {
            return
        }
        var updated = selection.wrappedValue
        if let index = updated.firstIndex(of: option) {
            updated.remove(at: index)
        } else {
            updated.append(option)
        }
        selection.wrappedValue = updated
        onSelectionChange?(updated)
    }

    private func proceed() {
        guard canProceed || showSkipButton else {
            return
        }
        preContinueAction {
            switch selectionMode {
            case let .single(_, _, completion):
                completion?()
            case let .multiple(_, _, completion):
                completion?()
            }
        }
    }
}

fileprivate enum QuizOptionExample: String, CaseIterable, Identifiable, TitleRepresentable {
    case one
    case two
    case three

    var id: String { rawValue }

    var title: String { rawValue.capitalized }
}

fileprivate struct OnboardingQuizViewPreview: View {
    @State private var selection: [QuizOptionExample] = [.one]

    var body: some View {
        OnboardingQuizView(
            question: .init(
                title: "Pick your swing speed",
                description: "Tempo Town will recommend the best tempo for you.",
                options: QuizOptionExample.allCases
            ),
            selection: $selection,
            showSkipButton: true,
            hint: .init(text: "You can change this later in Settings"),
            preContinueAction: { _ in }
        )
        .preferredColorScheme(.dark)
    }
}

#Preview {
    OnboardingQuizViewPreview()
}
