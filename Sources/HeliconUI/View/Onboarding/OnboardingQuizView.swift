//
//  OnboardingQuizView.swift
//
//  Created by Yuriy Nefedov on 09.11.2025.
//

import SwiftUI
import HeliconFoundation

public struct OnboardingQuizQuestion<T: Identifiable & Equatable & CaseIterable & TitleRepresentable> {
    public let title: String
    public var description: String?
    public let options: [T]
    public var defaultAnswer: T = .allCases.first!

    public init(
        title: String,
        description: String? = nil,
        options: [T],
        defaultAnswer: T = .allCases.first!
    ) {
        self.title = title
        self.description = description
        self.options = options
        self.defaultAnswer = defaultAnswer
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


public struct OnboardingQuizView<T: Identifiable & Equatable & CaseIterable & TitleRepresentable>: View {
    
    let backgroundColor: Color?
    let question: OnboardingQuizQuestion<T>
    let showSkipButton: Bool
    var hint: OnboardingQuizHint? = nil
    var preContinueAction: (@escaping () -> Void) -> ()
    var completion: ((T?) -> Void)?
    var onSelectionChange: ((T) -> Void)?
    @State private var selection: T
    
    public init(
        backgroundColor: Color? = nil,
        question: OnboardingQuizQuestion<T>,
        showSkipButton: Bool = false,
        hint: OnboardingQuizHint? = nil,
        preContinueAction: @escaping (@escaping () -> Void) -> (),
        onSelectionChange: ((T) -> Void)? = nil,
        completion: ((T?) -> Void)? = nil
    ) {
        self.backgroundColor = backgroundColor
        self.question = question
        self.showSkipButton = showSkipButton
        self.hint = hint
        self.preContinueAction = preContinueAction
        self.onSelectionChange = onSelectionChange
        self.completion = completion
        self._selection = State(initialValue: question.defaultAnswer)
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
                    header
                    Spacer().frame(height: 220)
                }
                .padding(.horizontal)
            }
            .scrollIndicators(.hidden)
            
            actionLayer
//                .ignoresSafeArea()
        }
        .onChange(of: selection) { _, newValue in
            onSelectionChange?(newValue)
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

            CardPicker(
                selection: $selection,
                direction: .vertical,
                options: question.options,
                hideLabels: true
            ) { option in
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
            } onDoubleSelect: {
                proceed()
            }
            
        }
        .font(.title3)
    }
    
//    private var picker: some View {
//
//    }
    
    @ViewBuilder
    private var continueButton: some View {
        continueButtonBase
            .glassOrBorderedProminent()
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
    
    private var blurLayer: some View {
        VStack {
            Spacer()
            progressiveBlurView
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
    
    private func proceed() {
        preContinueAction {
            completion?(selection)
        }
    }
}

//#Preview {
//    OnboardingQuizView(
//        question: .init(title: "Pick your swing speed", description: "Tempo Town will recommend the best tempo for you.", options: SwingSpeedPreset.allCases),
//        showSkipButton: true,
//        hint: .init(text: "You can change this later in Settings"),
//        preContinueAction: { _ in }
//    )
//        .preferredColorScheme(.dark)
//}

