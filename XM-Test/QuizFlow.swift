//
//  QuizFlow.swift
//  XM-Test
//
//  Created by Eduard Stern on 04.04.2024.
//

import Foundation
import ComposableArchitecture

@Reducer
public struct QuizFlow {

    @ObservableState
    public struct State: Equatable {
        var questions: [Question]
        var answers: [Answer] = []
        var currentAnswer: Answer?
        var currentQuestion: Question
        var currentQuestionNumber: Int = 0
        var isLoading = false
        var temporaryAnswer: Answer = .init()
        var screenState: ScreenState = .initial

        public enum ScreenState {
            case initial
            case shouldRetry
            case success

            var title: String {
                switch self {
                case .initial:
                    return "Submit"
                default:
                    return "Retry"
                }
            }
        }
    }

    public enum Action {
        case previousButtonTapped
        case nextButtonTapped
        case submitButtonTapped
        case answerSubmittedWithSuccess
        case answerSubmittedWithError
        case setAnswer(String)
        case isLoading
    }

    @Dependency(\.answerClient) var answerDependency

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .submitButtonTapped:
                state.isLoading = true
                let answer = state.temporaryAnswer
                return .run { send in
                    do {
                        let responseCode = try await answerDependency.postAnswer(answer)
                        if responseCode == 400 {
                            await send(.answerSubmittedWithError)
                        } else {
                            await send(.answerSubmittedWithSuccess)
                        }
                    } catch {
                        await send(.answerSubmittedWithError)
                    }
                }
            case .isLoading:
                return .none
            case let .setAnswer(value):
                if !value.isEmpty {
                    state.temporaryAnswer = Answer(id: state.currentQuestion.id,
                                                   value: value)
                }
                return .none
            case .answerSubmittedWithSuccess:
                state.isLoading = false
                state.screenState = .success
                state.answers.append(state.temporaryAnswer)
                state.temporaryAnswer = .init()
                if state.answers.count == state.questions.count {
                    print ("Finished")
                }
                return .run { send in
                    try await Task.sleep(for: .seconds(1))
                    await send(.nextButtonTapped)
                }
            case .answerSubmittedWithError:
                state.isLoading = false
                state.screenState = .shouldRetry
                return .none
            case .nextButtonTapped:
                if state.currentQuestionNumber < state.questions.count - 1 {
                    state.currentQuestionNumber += 1
                    state.currentQuestion = state.questions[state.currentQuestionNumber]
                    state.currentAnswer = state.answers.first { $0.id == state.currentQuestion.id }
                }
                state.screenState = .initial
                return .none
            case .previousButtonTapped:
                state.currentQuestionNumber -= 1
                state.currentQuestion = state.questions[state.currentQuestionNumber]
                state.currentAnswer = state.answers.first { $0.id == state.currentQuestion.id }
                state.screenState = .initial
                return .none
            }
        }
    }
}
