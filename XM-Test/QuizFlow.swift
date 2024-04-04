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
        var question: Question
        var answer: Answer?
        var questionNumber: Int
        var isLoading = false
        var totalQuestions: Int
        var questionsSubmitted: Int
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
        case delegate(Delegate)

        public enum Delegate: Equatable {
            case previous
            case next
            case submitAnswer(Answer)
        }
    }

    @Dependency(\.answerClient) var answerDependency

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .nextButtonTapped:
                return .send(.delegate(.next))
            case .previousButtonTapped:
                return .send(.delegate(.previous))
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
                    state.temporaryAnswer = Answer(id: state.question.id,
                                                   value: value)
                }
                return .none
            case .answerSubmittedWithSuccess:
                state.isLoading = false
                state.screenState = .success
                let answer = state.temporaryAnswer
                return .run { send in
                    try await Task.sleep(for: .seconds(1))
                    await send(.delegate(.submitAnswer(answer)))
                }
            case .answerSubmittedWithError:
                state.isLoading = false
                state.screenState = .shouldRetry
                return .none
            default:
                return .none
            }
        }
    }
}
