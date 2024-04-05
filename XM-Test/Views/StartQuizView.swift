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
        contentView
            .onAppear {
                store.send(.fetchQuestions)
            }
            .alert($store.scope(state: \.alert, action: \.alert))
    }
    
    @ViewBuilder
    var contentView: some View {
        if store.isLoading {
            ProgressView()
        } else if let firstQuestion = store.questions.first {
            NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
                NavigationLink(state: QuizFlow.State(questions: store.questions, currentQuestion: firstQuestion)) {
                    Text("Start survey")
                        .padding(.horizontal, 100)
                        .padding(.vertical, 20)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            } destination: { store in
                QuizView(store: store)
            }
            .navigationTitle("Welcome")
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
