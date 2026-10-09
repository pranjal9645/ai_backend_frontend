//
//  AuthManager.swift
//  AIKnowledgePlatform11
//
//  Created by Pranjal Singh on 08/10/26.
//

import Foundation

actor AuthManager {

    static let shared = AuthManager()

    private let tokenStore = TokenStore.shared

    private let baseURL = URL(
        string: "http://127.0.0.1:8000"
    )!

    private let session = URLSession.shared

    private var refreshTask:
        Task<TokenResponse, Error>?

    private init() {}

    func refreshAccessToken() async throws -> String {

        if let refreshTask {
            let response = try await refreshTask.value
            return response.accessToken
        }

        let task = Task {
            try await performRefresh()
        }

        refreshTask = task

        defer {
            refreshTask = nil
        }

        let response = try await task.value

        return response.accessToken
    }

    private func performRefresh()
        async throws -> TokenResponse {

        guard let refreshToken =
                tokenStore.readRefreshToken()
        else {

             expireAuthentication()

            throw APIError.authenticationFailed
        }

        let url = baseURL.appendingPathComponent(
            "auth/refresh"
        )

        var request = URLRequest(
            url: url
        )

        request.httpMethod = "POST"

        request.setValue(
            "application/json",
            forHTTPHeaderField:
                "Content-Type"
        )

        let body = [
            "refresh_token": refreshToken
        ]

        do {

            request.httpBody =
                try JSONSerialization.data(
                    withJSONObject: body
                )

        } catch {

            throw APIError.encodingError
        }

        do {

            let (data, response) =
                try await session.data(
                    for: request
                )

            guard let httpResponse =
                    response as? HTTPURLResponse
            else {

                throw APIError.invalidResponse
            }

            guard 200..<300 ~=
                    httpResponse.statusCode
            else {

                if httpResponse.statusCode == 401
                {
                    // The backend rejected the refresh credentials.
                    expireAuthentication()
                   throw APIError.authenticationFailed
                }
                // Preserve other HTTP failures, including server errors.
                throw APIError.httpError(statusCode: httpResponse.statusCode, message: nil)
            }

            let tokenResponse =
                try JSONDecoder().decode(
                    TokenResponse.self,
                    from: data
                )

            try tokenStore.saveAccessToken(
                tokenResponse.accessToken
            )

            try tokenStore.saveRefreshToken(
                tokenResponse.refreshToken
            )

            return tokenResponse

        } catch let error as APIError {

            throw error

        } catch is DecodingError {

              expireAuthentication()

            throw APIError.decodingError

        } catch {

            throw APIError.networkError(error)
        }
    }

    private func expireAuthentication() {

        tokenStore.deleteAllTokens()

        NotificationCenter.default.post(
            name: .authenticationExpired,
            object: nil
        )
    }
}
