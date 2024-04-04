//
//  StartQuizFlowTests.swift
//  XM-TestTests
//
//  Created by Eduard Stern on 04.04.2024.
//

import Foundation
import ComposableArchitecture
import XCTest
@testable import XM_Test

@MainActor
final class CounterFeatureTests: XCTestCase {

    func testStartWhenResponseIsSuccessful() async {

        let expectedQuestions: [Question] = [
            .mock(),
            .mock(id: 2, question: "What is your favourite food?")
        ]

        let store = TestStore(initialState: StartQuizFlow.State()) {
            StartQuizFlow()
        } withDependencies: {
            $0.questionsClient.getQuestions = { expectedQuestions }
        }

        await store.send(.startTapped) {
            $0.isLoading = true
        }

        await store.receive(\.questionsReceived) {
            $0.isLoading = false
            $0.questions = expectedQuestions
        }
    }

    func testStartWhenResponseIsError() async {
        let store = TestStore(initialState: StartQuizFlow.State()) {
            StartQuizFlow()
        } withDependencies: {
            $0.questionsClient.getQuestions = { throw URLError(.badURL) }
        }

        await store.send(.startTapped) {
            $0.isLoading = true
        }

        await store.receive(\.errorReceived) {
            $0.isLoading = false
            $0.questions = []
        }
    }
}
