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
        @Presents var alert: AlertState<Action.Alert>?
        var path = StackState<QuizFlow.State>()
        
        var questions: [Question] = []
        var isLoading = true
        var errorMessage: String = ""
    }
    
    public enum Action {
        case fetchQuestions
        case questionsReceived([Question])
        case errorReceived(String)
        case alert(PresentationAction<Alert>)
        case path(StackAction<QuizFlow.State, QuizFlow.Action>)
        
        public enum Alert: Equatable {
            case presentError
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
                        await send(.errorReceived("Error fetching questions: \(error.localizedDescription)"))
                    }
                }
            case let .questionsReceived(questions):
                state.isLoading = false
                state.questions = questions
                return .none
            case let .errorReceived(errorMessage):
                state.isLoading = false
                state.errorMessage = errorMessage
                return .send(.alert(.presented(.presentError)))
            case .alert(.presented(.presentError)):
                state.alert = AlertState {
                    TextState(state.errorMessage)
                }
                return .none
            case .alert:
                return .none
            case .path:
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
        .forEach(\.path, action: \.path) {
            QuizFlow()
        }
    }
}
