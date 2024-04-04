//
//  Question.swift
//  XM-Test
//
//  Created by Eduard Stern on 04.04.2024.
//

import Foundation

public struct Question: Codable, Equatable {
    let id: Int
    let value: String

    enum CodingKeys: String, CodingKey {
        case id
        case value = "question"
    }

    public init(id: Int = 0, question: String = "") {
        self.id = id
        self.value = question
    }
}
