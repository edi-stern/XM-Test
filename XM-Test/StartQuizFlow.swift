//
//  StartQuizFlow.swift
//  XM-Test
//
//  Created by Eduard Stern on 04.04.2024.
//

import Foundation
import ComposableArchitecture

@Reducer
public struct StartQuizFlow {

    @ObservableState
    public struct State: Equatable {
        @Presents var destination: Destination.State?

        var questions: [Question] = []
        var answers: [Answer] = []
        var isLoading = false
        var errorMessage: String? = nil
        var questionNumber = 0
    }

    public enum Action {
        case startTapped
        case questionsReceived([Question])
        case errorReceived(String)
        case startQuiz
        case destination(PresentationAction<Destination.Action>)

        public enum Alert: Equatable {
            case presentError(String)
        }
    }

    @Dependency(\.questionsClient) var questionsDependency

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .startTapped:
                state.isLoading = true
                return .run { send in
                    do {
                        let questions = try await questionsDependency.getQuestions()
                        await send(.questionsReceived(questions))
                    } catch {
                        await send(.errorReceived("Error fetching questions: \(error)"))
                    }
                }
            case let .questionsReceived(questions):
                state.isLoading = false
                state.questions = questions
                return .send(.startQuiz)
            case let .errorReceived(error):
                state.isLoading = false
                state.destination = .alert(AlertState {
                    TextState(error)
                })
                return .none
            case .startQuiz:
                state.destination = .quizFlow(QuizFlow.State(
                    question: state.questions[state.questionNumber],
                    answer: state.answers.first { $0.id == state.questions[state.questionNumber].id },
                    questionNumber: state.questionNumber,
                    totalQuestions: state.questions.count,
                    questionsSubmitted: state.answers.count
                ))
                return .none
            case let .destination(.presented(.quizFlow(.delegate(.submitAnswer(answer))))):
                state.answers.append(answer)
                state.questionNumber += 1
                return .send(.startQuiz)
            case .destination(.presented(.quizFlow(.delegate(.next)))):
                state.questionNumber += 1
                return .send(.startQuiz)
            case .destination(.presented(.quizFlow(.delegate(.previous)))):
                state.questionNumber -= 1
                return .send(.startQuiz)
            default:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

extension StartQuizFlow {
    @Reducer(state: .equatable)
    public enum Destination {
        case quizFlow(QuizFlow)
        case alert(AlertState<StartQuizFlow.Action.Alert>)
    }
}
