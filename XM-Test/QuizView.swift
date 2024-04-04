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
        NavigationStack {
            VStack(spacing: 20) {
                header
                questionText
                answerTextField
                Spacer()
                submitButton
            }
            .padding(.horizontal, 30)
            .navigationBarTitle("Question \(store.questionNumber + 1)/\(store.totalQuestions)")
            .toolbar {
                navigationButtons
            }
        }
    }

    // MARK: - Subviews

    private var textSubmittedQuestions: some View {
        Text("Questions submitted: \(store.questionsSubmitted)")
    }

    // Quiz Header
    private var header: some View {
        HStack {
            Spacer()
            textSubmittedQuestions
            Spacer()
        }
        .padding(.top, 20)
        .padding(.bottom, 50)
        .font(.headline)
    }

    // Question Text
    private var questionText: some View {
        Text(store.question.value)
            .font(.title)
            .padding()
    }

    // Answer TextField
    private var answerTextField: some View {
        TextField("Answer",
                  text: $store.temporaryAnswer.value.sending(\.setAnswer))
    }

    // Submit Button
    private var submitButton: some View {
        Button(action: {
            store.send(.submitButtonTapped)
        }) {
            Text("Submit")
                .padding(.horizontal, 100)
                .padding(.vertical, 20)
                .background(store.answer != nil ? Color.gray : Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
        }
        .disabled(store.answer != nil)
    }

    // Navigation Buttons
    private var navigationButtons: some view {
        HStack {
            Button("Previous") {
                store.send(.previousButtonTapped)
            }
            .disabled(store.questionNumber == 0)

            Spacer()

            Button("Next") {
                store.send(.nextButtonTapped)
            }
            .disabled(store.questionNumber == store.totalQuestions - 1)
        }
    }
}

#Preview {
    QuizView(store: .init(initialState: QuizFlow.State(question: .init(id: 0, question: "What is your favorite food")), reducer: { QuizFlow() }))
}
