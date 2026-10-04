//
//  APIError.swift
//  AIKnowledgePlatform1
//
//  Created by Pranjal Singh on 04/10/26.
//

import Foundation

enum APIError : Error
{
    case indvalidURL
    case invalidResponse
    case httpError(statusCode : Int)
    case decodingError
    case encodingError
    case networkError(Error)
}
