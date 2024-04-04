//
//  Answer.swift
//  XM-Test
//
//  Created by Eduard Stern on 04.04.2024.
//

import Foundation

public struct Answer: Codable, Equatable {
    let id: Int
    let value: String

    enum CodingKeys: String, CodingKey {
        case id
        case value = "answer"
    }

    public init(id: Int = 0, value: String = "") {
        self.id = id
        self.value = value
    }
}
