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
        let path = request.path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        
        let trailingSlash = request.path.hasSuffix("/") ? "/" : ""
        
        guard var components = URLComponents(url : baseURL , resolvingAgainstBaseURL: false) else
        {
            throw APIError.invalidURL
        }
        
        components.path = "/\(path)\(trailingSlash)"
        components.queryItems = request.queryItems.isEmpty ? nil : request.queryItems
        
        guard let url = components.url else
        {
            throw APIError.invalidURL
        }
       
        
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
            
            guard let token = tokenStore.readAccessToken() , !token.isEmpty else
            {
                if request.authenticationPolicy == .required
                {
                    throw APIError.authenticationFailed
                }
                break
            }
            
            urlRequest.setValue(
                  "Bearer \(token)",
                  forHTTPHeaderField: "Authorization"
              )

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
        
        let statusCode = httpResponse.statusCode
        let errorDetails = extractErrorDeatils(from: data)
        
        // Handle unauthorized responses according to the request's explicit retry policy.
        if statusCode == 401
        {
            switch request.unauthorizedRetryPolicy {
            case .never:
                
                throw APIError.httpError(statusCode: 401, message: errorDetails.message)
                
            case .refreshAccessTokenOnce:
                
                if isRetry
                {
                    throw APIError.authenticationFailed
                }
                
                do
                {
                    _ = try await AuthManager.shared.refreshAccessToken()
                }
                catch let error as APIError
                {
                    throw error
                }
                catch
                {
                    // Preserve the original refresh error.
                    throw APIError.networkError(error)
                }
                
                return try await send(request , isRetry: true)
            }
        }
        
        // Handle rate limiting without refreshing tokens or retrying.
        if statusCode == 429
        {
            let retryAfter = parseRetryAfter(httpResponse.value(forHTTPHeaderField: "Retry-After"))
            
            let message = errorDetails.message ?? "Too many requests. Please try again later."
            
            throw APIError.rateLimitExceeded(retryAfter: retryAfter, message: message)
        }
        
        // A rate-limiting service outage is not an authentication failure.
        
        if statusCode == 503
        {
            throw APIError.serviceUnavailable(message: errorDetails.message ?? "The service is temporarily unavailable. Please try again later.")
        }
        
        guard 200..<300 ~= httpResponse.statusCode else
        {
            throw APIError.httpError(statusCode: httpResponse.statusCode , message: errorDetails.message)
        }
        
        do
        {
            return try JSONDecoder().decode(T.self, from: data)
        }catch
        {
            throw APIError.decodingError
        }
        
    }
    
    private func extractErrorDeatils(from data : Data) -> (code: String? , message : String?)
    {
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String : Any] else
        {
            return (nil , nil)
        }
        
        if let error = json["error"] as? [String : Any]
        {
            let code = error["code"] as? String
            let message = error["message"] as? String
            
            return (code , message)
        }
        
        if let detail = json["detail"] as? String
        {
            return (nil , detail)
        }
        
        return (nil , nil)
    }
    
    private func parseRetryAfter(_ headerValue : String?) -> TimeInterval?
    {
        guard let headerValue else
        {
            return nil
        }
        
        if let seconds = TimeInterval(headerValue) , seconds >= 0 {
            return seconds
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateFormat = "EEE',' dd MMM yyyy HH':'mm':'ss z"
        
        guard let date = dateFormatter.date(from: headerValue) else
        {
            return nil
        }
        
        return max(0 , date.timeIntervalSinceNow)
    }
}
