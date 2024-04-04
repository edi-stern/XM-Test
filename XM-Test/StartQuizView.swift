//
//  ContentView.swift
//  XM-Test
//
//  Created by Eduard Stern on 04.04.2024.
//

import SwiftUI
import ComposableArchitecture

struct StartQuizView: View {

    @Bindable var store: StoreOf<StartQuizFlow>

    var body: some View {
        NavigationStack {
            if store.isLoading {
                ProgressView()
            } else {
                VStack {
                    Spacer()
                    startSurveyButton
                    Spacer()
                }
            }
        }
        .fullScreenCover(
            item: $store.scope(state: \.destination?.quizFlow, action: \.destination.quizFlow)
        ) { quizStore in
            NavigationStack {
                QuizView(store: quizStore)
            }
        }
        .navigationTitle("Welcome")
        .alert($store.scope(state: \.destination?.alert,
                            action: \.destination.alert))
    }

    // MARK: - Subviews

    private var startSurveyButton: some View {
        Button {
            store.send(.startTapped)
        } label: {
            Text("Start survey")
                .padding(.horizontal, 100)
                .padding(.vertical, 20)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
        }
    }
}

#if DEBUG
    struct StartQuizView_Previews: PreviewProvider {
        static var previews: some View {
            StartQuizView(store: .init(initialState: StartQuizFlow.State(), reducer: {
                StartQuizFlow()
            }))
        }
    }
#endif
