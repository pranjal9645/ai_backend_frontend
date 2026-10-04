//
//  APIClient.swift
//  AIKnowledgePlatform1
//
//  Created by Pranjal Singh on 04/10/26.
//

import Foundation

final class APIClient
{
    static let shared = APIClient()
    
    private let baseURL = URL(string: "http://127.0.0.1:8000")!
    
    private let session : URLSession
    
    private let tokenStore = TokenStore.shared
    
    private init()
    {
        self.session = .shared
    }
    
    func send<T : Decodable>(_ request : APIRequest) async throws -> T
    {
        let url = baseURL.appendingPathComponent(request.path.trimmingCharacters(in: CharacterSet(charactersIn: "/")))
        
        var urlRequest = URLRequest(url: url)
        
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.httpBody = request.body
        
        for (key , value) in request.headers
        {
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }
        
        if let token = tokenStore.readToken()
        {
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField:"Authorization")
        }
        
        let (data , response) : (Data , URLResponse)
        
        do
        {
            (data , response) = try await session.data(for: urlRequest)
        }catch
        {
            throw APIError.networkError(error)
        }
        
        guard let httpResponse = response as? HTTPURLResponse else
        {
            throw APIError.invalidResponse
        }
        
        guard 200..<300 ~= httpResponse.statusCode else
        {
            throw APIError.httpError(statusCode: httpResponse.statusCode)
        }
        
        do
        {
            return try JSONDecoder().decode(T.self, from: data)
        }catch
        {
            throw APIError.decodingError
        }
        
        
    }
}
