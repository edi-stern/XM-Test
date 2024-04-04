//
//  XM_TestApp.swift
//  XM-Test
//
//  Created by Eduard Stern on 04.04.2024.
//

import SwiftUI
import ComposableArchitecture

@main
struct XM_TestApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(store: Store(initialState: StartQuizFlow.State(), reducer: {
                StartQuizFlow()
            }))
        }
    }
}
