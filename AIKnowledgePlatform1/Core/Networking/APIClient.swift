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
    
    func send<T : Decodable>(_ request : APIRequest , isRetry : Bool = false) async throws -> T
    {
        let url = baseURL.appendingPathComponent(request.path.trimmingCharacters(in: CharacterSet(charactersIn: "/")))
        
        var urlRequest = URLRequest(url: url)
        
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.httpBody = request.body
        
        for (key , value) in request.headers
        {
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }
        
        // Attach the access token only when the request's authentication policy allows it.
        switch request.authenticationPolicy {
        case .none:
            break
        case .optional , .required:
            
            if let token = tokenStore.readAccessToken()
            {
              urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }else if request.authenticationPolicy == .required
            {
                throw APIError.authenticationFailed
            }
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
        
        // Handle unauthorized responses according to the request's explicit retry policy.
        if httpResponse.statusCode == 401
        {
            switch request.unauthorizedRetryPolicy {
            case .never:
                
                let message = extractErrorMessage(from: data)
                
                throw APIError.httpError(statusCode: 401, message: message)
                
            case .refreshAccessTokenOnce:
                
                if isRetry
                {
                    throw APIError.authenticationFailed
                }
                
                do
                {
                    _ = try await AuthManager.shared.refreshAccessToken()
                }catch
                {
                    // Preserve the original refresh error.
                    throw APIError.networkError(error)
                }
                
                return try await send(request , isRetry: true)
            }
        }
        
        guard 200..<300 ~= httpResponse.statusCode else
        {
            let message = extractErrorMessage(from : data)
            throw APIError.httpError(statusCode: httpResponse.statusCode , message: message)
        }
        
        do
        {
            return try JSONDecoder().decode(T.self, from: data)
        }catch
        {
            throw APIError.decodingError
        }
        
    }
    
    private func extractErrorMessage(from data : Data) -> String?
    {
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String : Any] else
        {
            return nil
        }
        
        if let detail = json["detail"] as? String
        {
            return detail
        }
        
        return nil
    }
}
