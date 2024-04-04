//
//  QuestionMock.swift
//  XM-TestTests
//
//  Created by Eduard Stern on 04.04.2024.
//

import XCTest
@testable import XM_Test

extension Question {
    
    public static func mock(
        id: Int = 0,
        question: String = "What is your favourite colour?") -> Self {
        return .init(
            id: id,
            question: question
        )
    }
}
