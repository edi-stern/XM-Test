//
//  AnswerClient.swift
//  XM-Test
//
//  Created by Eduard Stern on 04.04.2024.
//

import Foundation
import ComposableArchitecture

struct AnswerClient {
    var postAnswer: (Answer) async throws -> (Int)
}

extension AnswerClient: DependencyKey {
    static let liveValue: AnswerClient  = Self { answer in
        let url = URL(string: "https://xm-assignment.web.app/question/submit")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try JSONEncoder().encode(answer)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        return httpResponse.statusCode
    }
}

extension DependencyValues {
    var answerClient: AnswerClient {
        get { self[AnswerClient.self] }
        set { self[AnswerClient.self] = newValue }
    }
}
