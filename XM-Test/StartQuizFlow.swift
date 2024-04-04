//
//  StartQuizFlow.swift
//  XM-Test
//
//  Created by Eduard Stern on 04.04.2024.
//

import ComposableArchitecture

@Reducer
struct StartQuizFlow {

    @ObservableState
    struct State {

    }

    enum Action {
        case start
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .start:
                return .none
            }
        }
    }
}
