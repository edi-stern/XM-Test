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
        var question: Question = .init()
        var answer: Answer? = nil
        var questionNumber: Int = 0
        var isLoading = false
        var totalQuestions = 0
        var questionsSubmitted = 0
        var temporaryAnswer: Answer = .init()
    }

    public enum Action {
        case previousButtonTapped
        case nextButtonTapped
        case submitButtonTapped
        case setAnswer(String)
        case isLoading
        case delegate(Delegate)

        public enum Delegate: Equatable {
            case previous
            case next
            case submitAnswer(Answer)
        }
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .nextButtonTapped:
                return .send(.delegate(.next))
            case .previousButtonTapped:
                return .send(.delegate(.previous))
            case .submitButtonTapped:
                if !state.temporaryAnswer.value.isEmpty {
                    return .send(.delegate(.submitAnswer(state.temporaryAnswer)))
                }
                return .none
            case .isLoading:
                return .none
            case let .setAnswer(value):
                if !value.isEmpty {
                    state.temporaryAnswer = Answer(id: state.question.id,
                                                   value: value)
                }
                return .none
            default:
                return .none
            }
        }
    }
}
