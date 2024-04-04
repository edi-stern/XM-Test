//
//  ContentView.swift
//  XM-Test
//
//  Created by Eduard Stern on 04.04.2024.
//

import SwiftUI
import ComposableArchitecture

struct ContentView: View {

    let store: StoreOf<StartQuizFlow>

    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                Button {
                    store.send(.start)
                } label: {
                    Text("Start survey")
                        .padding(.horizontal, 100)
                        .padding(.vertical, 20)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                Spacer()
            }

        }
        .navigationBarTitle("Welcome")
    }
}

#Preview {
    ContentView(store: .init(initialState: StartQuizFlow.State(), reducer: {
        StartQuizFlow()
    }))
}
