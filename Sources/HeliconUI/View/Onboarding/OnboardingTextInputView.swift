//
//  OnboardingTextInputView.swift
//
//  Created by Yuriy Nefedov on 19.02.2026.
//

import SwiftUI

public struct OnboardingTextInputQuestion {
    public let title: String
    public var description: String?
    public var placeholder: String
    public var defaultAnswer: String

    public init(
        title: String,
        description: String? = nil,
        placeholder: String = "",
        defaultAnswer: String = ""
    ) {
        self.title = title
        self.description = description
        self.placeholder = placeholder
        self.defaultAnswer = defaultAnswer
    }
}

public struct OnboardingTextInputTraits {
    public var keyboardType: UIKeyboardType
    public var autocapitalization: TextInputAutocapitalization?
    public var autocorrectionDisabled: Bool

    public init(
        keyboardType: UIKeyboardType = .default,
        autocapitalization: TextInputAutocapitalization? = .sentences,
        autocorrectionDisabled: Bool = true
    ) {
        self.keyboardType = keyboardType
        self.autocapitalization = autocapitalization
        self.autocorrectionDisabled = autocorrectionDisabled
    }
}

public enum OnboardingTextInputValidationState: Equatable {
    case valid
    case invalid(message: String?)
}

public struct OnboardingTextInputView: View {

    let backgroundColor: Color?
    let question: OnboardingTextInputQuestion
    let showSkipButton: Bool
    let autoFocusOnAppear: Bool
    let inputTraits: OnboardingTextInputTraits
    let validator: ((String) -> OnboardingTextInputValidationState)?
    let showsValidationMessage: Bool
    var hint: OnboardingQuizHint? = nil
    var preContinueAction: (@escaping () -> Void) -> ()
    var completion: ((String) -> Void)?
    var onTextChange: ((String) -> Void)?
    var onValidationChange: ((OnboardingTextInputValidationState) -> Void)?
    @State private var answer: String
    @State private var validationState: OnboardingTextInputValidationState
    @State private var hasValidationAttempt: Bool
    @FocusState private var isTextFieldFocused: Bool

    public init(
        backgroundColor: Color? = nil,
        question: OnboardingTextInputQuestion,
        showSkipButton: Bool = false,
        autoFocusOnAppear: Bool = true,
        inputTraits: OnboardingTextInputTraits = .init(),
        validator: ((String) -> OnboardingTextInputValidationState)? = nil,
        showsValidationMessage: Bool = true,
        onValidationChange: ((OnboardingTextInputValidationState) -> Void)? = nil,
        hint: OnboardingQuizHint? = nil,
        preContinueAction: @escaping (@escaping () -> Void) -> (),
        onTextChange: ((String) -> Void)? = nil,
        completion: ((String) -> Void)? = nil
    ) {
        self.backgroundColor = backgroundColor
        self.question = question
        self.showSkipButton = showSkipButton
        self.autoFocusOnAppear = autoFocusOnAppear
        self.inputTraits = inputTraits
        self.validator = validator
        self.showsValidationMessage = showsValidationMessage
        self.onValidationChange = onValidationChange
        self.hint = hint
        self.preContinueAction = preContinueAction
        self.onTextChange = onTextChange
        self.completion = completion
        self._answer = State(initialValue: question.defaultAnswer)
        self._validationState = State(initialValue: .valid)
        self._hasValidationAttempt = State(initialValue: false)
    }

    public var body: some View {
        ZStack(alignment: .center) {

            if let backgroundColor {
                backgroundColor
                    .ignoresSafeArea()
            }
            ZStack {
                VStack(spacing: 0) {
                    Spacer().frame(height: 32)
                    header
                    Spacer()
                }
                .padding(.horizontal)
                textInput
                    .padding(.horizontal)
            }

            actionLayer
        }
        .onChange(of: answer) { _, newValue in
            onTextChange?(newValue)
            guard hasValidationAttempt else {
                return
            }
            withAnimation(.easeInOut(duration: 0.2)) {
                hasValidationAttempt = false
            }
        }
        .onAppear {
            guard autoFocusOnAppear else {
                return
            }
            DispatchQueue.main.async {
                isTextFieldFocused = true
            }
        }
        .toolbar(.hidden)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 24) {

            Text(question.title)
                .font(.largeTitle.bold())
            if let description = question.description {
                Text(description)
                    .opacity(Opacity.textQuiet)
            }
        }
        .font(.title3)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var textInputWrapper: some View {
        GeometryReader { proxy in
            textInput
                .position(
                    x: proxy.size.width / 2,
                    y: proxy.size.height / 2
                )
        }
    }

    private var textInput: some View {
        VStack(spacing: 8) {
            TextField(question.placeholder, text: $answer)
                .textFieldStyle(.plain)
                .font(.largeTitle.weight(.regular))
                .multilineTextAlignment(.center)
                .lineLimit(1)
                .keyboardType(inputTraits.keyboardType)
                .textInputAutocapitalization(inputTraits.autocapitalization)
                .autocorrectionDisabled(inputTraits.autocorrectionDisabled)
                .submitLabel(.done)
                .focused($isTextFieldFocused)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity, minHeight: 72, alignment: .center)

            if showsValidationMessage, let validationMessage {
                Text(validationMessage)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .transition(.opacity.combined(with: .scale(scale: 0.98)))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: validationMessage)
    }

    @ViewBuilder
    private var continueButton: some View {
        continueButtonBase
            .glassOrBorderedProminent()
            .opacityDisabled(!canProceed)
            .disabled(!canProceed)
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
            .opacityDisabled(!canProceed)
            .disabled(!canProceed)
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

    private var canProceed: Bool {
        !trimmedAnswer.isEmpty
    }

    private var trimmedAnswer: String {
        answer.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var validationMessage: String? {
        guard hasValidationAttempt else {
            return nil
        }
        guard case let .invalid(message) = validationState else {
            return nil
        }
        guard let message, !message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return nil
        }
        return message
    }

    private func resolveValidationState(for input: String) -> OnboardingTextInputValidationState {
        Self.resolveValidationState(for: input, validator: validator)
    }

    private static func resolveValidationState(
        for input: String,
        validator: ((String) -> OnboardingTextInputValidationState)?
    ) -> OnboardingTextInputValidationState {
        guard let validator else {
            return .valid
        }
        return validator(input)
    }

    private func proceed() {
        guard canProceed else {
            return
        }
        let nextValidationState = resolveValidationState(for: trimmedAnswer)
        let didValidationStateChange = validationState != nextValidationState
        withAnimation(.easeInOut(duration: 0.2)) {
            hasValidationAttempt = true
            if didValidationStateChange {
                validationState = nextValidationState
            }
        }
        if didValidationStateChange {
            onValidationChange?(nextValidationState)
        }
        guard nextValidationState == .valid else {
            return
        }
        preContinueAction {
            completion?(trimmedAnswer)
        }
    }
}

#Preview("Default") {
    OnboardingTextInputView(
        question: .init(
            title: "Describe goal",
            description: "Add a short note.",
            placeholder: "My goal"
        ),
        showSkipButton: false,
        hint: .init(text: "You can change this later in Settings"),
        preContinueAction: { _ in }
    )
    .preferredColorScheme(.dark)
}

#Preview("Validator") {
    OnboardingTextInputView(
        question: .init(
            title: "Create username",
            description: "Use lowercase letters, numbers, or underscores.",
            placeholder: "@creator",
            defaultAnswer: "no"
        ),
        inputTraits: .init(
            keyboardType: .asciiCapable,
            autocapitalization: .never,
            autocorrectionDisabled: true
        ),
        validator: { input in
            guard input.count >= 3 else {
                return .invalid(message: "Use at least 3 characters.")
            }
            let isValid = input.allSatisfy { $0.isLetter || $0.isNumber || $0 == "_" }
            return isValid ? .valid : .invalid(message: "Use only letters, numbers, or underscores.")
        },
        preContinueAction: { _ in }
    )
    .preferredColorScheme(.dark)
}
