//
//  QuestionsClient.swift
//  XM-Test
//
//  Created by Eduard Stern on 04.04.2024.
//

import Foundation
import ComposableArchitecture

// TODO: Move logic into network layer

struct QuestionsClient {
    var getQuestions: () async throws -> [Question]
}

extension QuestionsClient: DependencyKey {
    static let liveValue: QuestionsClient  = Self(
        getQuestions: {
            
            let url = URL(string: "\(Constants.baseURL)/questions")!
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoder = JSONDecoder()
            let questions = try decoder.decode([Question].self, from: data)
            return questions
        }
    )
}

extension DependencyValues {
    var questionsClient: QuestionsClient {
        get { self[QuestionsClient.self] }
        set { self[QuestionsClient.self] = newValue }
    }
}
