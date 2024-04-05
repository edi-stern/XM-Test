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
        @Presents var alert: AlertState<Action.Alert>?
        
        var questions: [Question]
        var answers: [Answer] = []
        var currentAnswer: Answer?
        var currentQuestion: Question
        var currentIndex: Int = 0
        var isLoading = false
        var temporaryAnswer: Answer = .init()
        var resultState: ResultState = .initial

        public enum ResultState {
            case initial
            case error
            case success

            var buttonTitle: String {
                switch self {
                case .initial:
                    return "Submit"
                default:
                    return "Retry"
                }
            }

            var resultTitle: String {
                switch self {
                case .initial:
                    return ""
                case .error:
                    return "Failure!"
                case .success:
                    return "Success"
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
        case update(Int)
        case setAnswer(String)
        case surveyFinished
        case isLoading
        case alert(PresentationAction<Alert>)

        public enum Alert: Equatable {
            case presentSurveyFinished
        }
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
                state.resultState = .success
                state.answers.append(state.temporaryAnswer)
                state.temporaryAnswer = .init()
                let finishedSurvey = state.answers.count == state.questions.count
                return .run { send in
                    try await Task.sleep(for: .seconds(1))
                    await send(finishedSurvey ? .surveyFinished : .nextButtonTapped)
                }
            case .answerSubmittedWithError:
                state.isLoading = false
                state.resultState = .error
                return .none
            case .nextButtonTapped:
                return .send(.update(state.currentIndex + 1))
            case .previousButtonTapped:
                return .send(.update(state.currentIndex - 1))
            case let .update(newIndex):
                state.resultState = .initial
                guard newIndex >= 0 && newIndex < state.questions.count else {
                    return .none
                }

                state.currentIndex = newIndex
                let newQuestion = state.questions[newIndex]
                state.currentQuestion = newQuestion
                state.currentAnswer = state.answers.first { $0.id == newQuestion.id }
                return .none
            case .surveyFinished:
                return .send(.alert(.presented(.presentSurveyFinished)))
            case .alert(.presented(.presentSurveyFinished)):
                state.alert = AlertState {
                    TextState("Thank you for responding to all our questions!")
                }
                return .none
            case .alert:
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
    }
}
