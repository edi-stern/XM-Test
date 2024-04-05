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
final class StartQuizFlowTests: XCTestCase {

    func testStartWhenResponseIsSuccessful() async {
        // Given
        let expectedQuestions: [Question] = [
            .mock(),
            .mock(id: 2, question: "What is your favourite food?")
        ]

        let store = TestStore(initialState: StartQuizFlow.State()) {
            StartQuizFlow()
        } withDependencies: {
            $0.questionsClient.getQuestions = { expectedQuestions }
        }

        // When
        await store.send(.fetchQuestions)

        // Then
        await store.receive(\.questionsReceived) {
            $0.isLoading = false
            $0.questions = expectedQuestions
        }
    }

//    func testStartWhenResponseIsError() async {
//        // Given
//        let expectedError = URLError(.badURL)
//        let store = TestStore(initialState: StartQuizFlow.State()) {
//            StartQuizFlow()
//        } withDependencies: {
//            $0.questionsClient.getQuestions = { throw expectedError }
//        }
//
//        // When
//        await store.send(.fetchQuestions)
//
//        // Then
//        await store.receive(\.errorReceived) {
//            $0.isLoading = false
//            $0.errorMessage = "Error fetching questions: \(expectedError.localizedDescription)"
//        }
//
//        await store.receive(\.alert) {
//            $0.alert = AlertState {
//                TextState(verbatim: "Error fetching questions: \(expectedError.localizedDescription)")
//            }
//        }
//    }

}
