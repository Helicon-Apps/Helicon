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

public struct OnboardingTextInputView: View {

    let backgroundColor: Color?
    let question: OnboardingTextInputQuestion
    let showSkipButton: Bool
    var hint: OnboardingQuizHint? = nil
    var preContinueAction: (@escaping () -> Void) -> ()
    var completion: ((String) -> Void)?
    var onTextChange: ((String) -> Void)?
    @State private var answer: String

    public init(
        backgroundColor: Color? = nil,
        question: OnboardingTextInputQuestion,
        showSkipButton: Bool = false,
        hint: OnboardingQuizHint? = nil,
        preContinueAction: @escaping (@escaping () -> Void) -> (),
        onTextChange: ((String) -> Void)? = nil,
        completion: ((String) -> Void)? = nil
    ) {
        self.backgroundColor = backgroundColor
        self.question = question
        self.showSkipButton = showSkipButton
        self.hint = hint
        self.preContinueAction = preContinueAction
        self.onTextChange = onTextChange
        self.completion = completion
        self._answer = State(initialValue: question.defaultAnswer)
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
        TextField(question.placeholder, text: $answer)
            .textFieldStyle(.plain)
            .font(.largeTitle.weight(.regular))
            .multilineTextAlignment(.center)
            .lineLimit(1)
            .textInputAutocapitalization(.sentences)
            .autocorrectionDisabled()
            .submitLabel(.done)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, minHeight: 72, alignment: .center)
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
            .opacityDisabled(!canProceed)
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

    private func proceed() {
        guard canProceed else {
            return
        }
        preContinueAction {
            completion?(trimmedAnswer)
        }
    }
}

#Preview {
    OnboardingTextInputView(
        question: .init(
            title: "Describe your golf goal",
            description: "Add a short note so Tempo Town can tailor recommendations for you.",
            placeholder: "My goal"
        ),
        showSkipButton: false,
        hint: .init(text: "You can change this later in Settings"),
        preContinueAction: { _ in }
    )
    .preferredColorScheme(.dark)
}
