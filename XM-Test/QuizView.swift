//
//  QuizView.swift
//  XM-Test
//
//  Created by Eduard Stern on 04.04.2024.
//

import SwiftUI
import ComposableArchitecture

struct QuizView: View {
    @Bindable var store: StoreOf<QuizFlow>

    var body: some View {
        if store.isLoading {
            ProgressView()
        } else {
            VStack(spacing: 20) {
                header
                questionText
                if store.screenState != .success {
                    answerTextField
                }
                Spacer()
                if store.screenState != .success {
                    submitButton
                }
            }
            .padding(.horizontal, 30)
            .navigationBarTitle("Question \(store.currentQuestionNumber + 1)/\(store.questions.count)")
            .toolbar {
                navigationButtons
            }
            .background(backgroundColor)
        }
    }

    // MARK: - Colors

    private var backgroundColor: Color {
        switch store.screenState {
        case .initial:
            return .clear
        case .shouldRetry:
            return .red
        case .success:
            return .green
        }
    }


    // MARK: - Subviews

    private var textSubmittedQuestions: some View {
        Text("Questions submitted: \(store.answers.count)")
    }

    // Quiz Header
    private var header: some View {
        HStack {
            Spacer()
            textSubmittedQuestions
            Spacer()
        }
        .padding(.top, 40)
        .padding(.bottom, 50)
        .font(.headline)
    }

    // Question Text
    private var questionText: some View {
        Text(store.currentQuestion.value)
            .font(.title)
            .multilineTextAlignment(.center)
            .padding()
    }

    // Answer TextField
    private var answerTextField: some View {
        TextField(store.currentAnswer?.value ?? "Type your answer here",
                  text: $store.temporaryAnswer.value.sending(\.setAnswer))
        .disabled(store.currentAnswer != nil)
        .multilineTextAlignment(.center)
        .foregroundColor(store.currentAnswer != nil ? .black : .gray)
    }

    // Submit Button
    private var submitButton: some View {
        Button(action: {
            store.send(.submitButtonTapped)
        }) {
            Text(store.screenState.title)
                .padding(.horizontal, 100)
                .padding(.vertical, 20)
                .background(store.currentAnswer != nil || store.temporaryAnswer.value.isEmpty ? Color.gray : Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
        }
        .disabled(store.currentAnswer != nil || store.temporaryAnswer.value.isEmpty)
    }

    // Navigation Buttons
    private var navigationButtons: some View {
        HStack {
            Button("Previous") {
                store.send(.previousButtonTapped)
            }
            .disabled(store.currentQuestionNumber == 0)

            Spacer()

            Button("Next") {
                store.send(.nextButtonTapped)
            }
            .disabled(store.currentQuestionNumber == store.questions.count - 1)
        }
    }
}

#Preview {
    QuizView(store: .init(initialState: QuizFlow.State(questions: [], currentQuestion: .init()), reducer: { QuizFlow() }))
}
