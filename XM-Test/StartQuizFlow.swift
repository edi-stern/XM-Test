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
        var path = StackState<QuizFlow.State>()
        
        var questions: [Question] = []
        var isLoading = true
        var errorMessage: String? = nil
    }

    public enum Action {
        case fetchQuestions
        case questionsReceived([Question])
        case errorReceived(String)
        case destination(PresentationAction<Destination.Action>)
        case path(StackAction<QuizFlow.State, QuizFlow.Action>)

        public enum Alert: Equatable {
            case presentError(String)
        }
    }

    @Dependency(\.questionsClient) var questionsDependency

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .fetchQuestions:
                return .run { send in
                    do {
                        let questions = try await questionsDependency.getQuestions()
                        if questions.count == 0 {
                            await send(.errorReceived("There are no questions in survey, please come later"))
                        } else {
                            await send(.questionsReceived(questions))
                        }
                    } catch {
                        await send(.errorReceived("Error fetching questions: \(error)"))
                    }
                }
            case let .questionsReceived(questions):
                state.isLoading = false
                state.questions = questions
                return .none
            case let .errorReceived(error):
                state.isLoading = false
                state.destination = .alert(AlertState {
                    TextState(error)
                })
                return .none
            default:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
        .forEach(\.path, action: \.path) {
            QuizFlow()
        }
    }
}

extension StartQuizFlow {
    @Reducer(state: .equatable)
    public enum Destination {
        case alert(AlertState<StartQuizFlow.Action.Alert>)
    }
}
