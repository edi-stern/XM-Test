//
//  AnswerMock.swift
//  XM-TestTests
//
//  Created by Eduard Stern on 05.04.2024.
//

import XCTest
@testable import XM_Test

extension Answer {

    public static func mock(
        id: Int = 0,
        answer: String = "My favourite colour is red") -> Self {
        return .init(
            id: id,
            value: answer
        )
    }
}
