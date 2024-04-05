//
//  QuizFlowTests.swift
//  XM-TestTests
//
//  Created by Eduard Stern on 05.04.2024.
//

import Foundation
import Foundation
import ComposableArchitecture
import XCTest
@testable import XM_Test

@MainActor
final class QuizFlowTests: XCTestCase {

    func testPreviousButtonTappedSuccess() async {
        // Given

        let store = TestStore(initialState: QuizFlow.State(
            questions: [.mock(),
                        .mock(id: 2, question: "What is your favourite food?")],
            currentQuestion: .mock(id: 2, question: "What is your favourite food?"),
            currentIndex: 1
        )) {
            QuizFlow()
        }

        // When
        await store.send(.previousButtonTapped)

        // Then
        await store.receive(\.update) {
            $0.isLoading = false
            $0.currentIndex = 0
            $0.currentQuestion = .mock()
        }
    }

    func testPreviousButtonTappedFail() async {
        // Given

        let store = TestStore(initialState: QuizFlow.State(
            questions: [.mock(),
                        .mock(id: 2, question: "What is your favourite food?")],
            currentQuestion: .mock(),
            currentIndex: 0
        )) {
            QuizFlow()
        }

        // When
        await store.send(.previousButtonTapped)

        // Then
        await store.receive(\.update)
    }

    func testNextButtonTappedSuccess() async {
        // Given

        let store = TestStore(initialState: QuizFlow.State(
            questions: [.mock(),
                        .mock(id: 2, question: "What is your favourite food?")],
            currentQuestion: .mock(),
            currentIndex: 0
        )) {
            QuizFlow()
        }

        // When
        await store.send(.nextButtonTapped)

        // Then
        await store.receive(\.update) {
            $0.isLoading = false
            $0.currentIndex = 1
            $0.currentQuestion = .mock(id: 2, question: "What is your favourite food?")
        }
    }

    func testNextButtonTappedFail() async {
        // Given

        let store = TestStore(initialState: QuizFlow.State(
            questions: [.mock(),
                        .mock(id: 2, question: "What is your favourite food?")],
            currentQuestion: .mock(id: 2, question: "What is your favourite food?"),
            currentIndex: 1
        )) {
            QuizFlow()
        }

        // When
        await store.send(.nextButtonTapped)

        // Then
        await store.receive(\.update)
    }

    func testSetAnswer() async {
        // Given

        let store = TestStore(initialState: QuizFlow.State(
            questions: [.mock(),
                        .mock(id: 2, question: "What is your favourite food?")],
            currentQuestion: .mock(),
            currentIndex: 0
        )) {
            QuizFlow()
        }

        // When
        await store.send(.setAnswer("Test")){
            $0.temporaryAnswer = Answer.mock(answer: "Test")
        }
    }

    func testSubmitWithSuccess() async {
        // Given
        let store = TestStore(initialState: QuizFlow.State(
            questions: [.mock(), .mock(id: 2, question: "What is your favourite food?")],
            currentQuestion: .mock(),
            currentIndex: 0,
            temporaryAnswer: .mock()
        )) {
            QuizFlow()
        } withDependencies: {
            $0.answerClient.postAnswer = { _ in
                return 200
            }
        }

        // When
        await store.send(.submitButtonTapped) {
            $0.isLoading = true
        }

        // Then
        await store.receive(\.answerSubmittedWithSuccess) {
            $0.isLoading = false
            $0.resultState = .success
            $0.answers = [.mock()]
            $0.temporaryAnswer = .init()
        }

        await store.receive(\.nextButtonTapped)

        await store.receive(\.update) {
            $0.isLoading = false
            $0.currentIndex = 1
            $0.currentQuestion = .mock(id: 2, question: "What is your favourite food?")
            $0.resultState = .initial
        }
    }

    func testSubmitWithFail() async {
        // Given
        let store = TestStore(initialState: QuizFlow.State(
            questions: [.mock(), .mock(id: 2, question: "What is your favourite food?")],
            currentQuestion: .mock(),
            currentIndex: 0,
            temporaryAnswer: .mock()
        )) {
            QuizFlow()
        } withDependencies: {
            $0.answerClient.postAnswer = { _ in
                return 400
            }
        }

        // When
        await store.send(.submitButtonTapped) {
            $0.isLoading = true
        }

        // Then
        await store.receive(\.answerSubmittedWithError) {
            $0.isLoading = false
            $0.resultState = .error
        }
    }

}
