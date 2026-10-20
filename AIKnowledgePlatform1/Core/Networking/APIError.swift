//
//  APIError.swift
//  AIKnowledgePlatform1
//
//  Created by Pranjal Singh on 04/10/26.
//

import Foundation

enum APIError: Error {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int, message: String?)
    case authenticationFailed
    case rateLimitExceeded(retryAfter: TimeInterval?, message: String)
    case serviceUnavailable(message: String)
    case decodingError
    case encodingError
    case networkError(Error)
}
