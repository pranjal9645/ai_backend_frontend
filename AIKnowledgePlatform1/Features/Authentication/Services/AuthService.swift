//
//  AuthService.swift
//  AIKnowledgePlatform1
//
//  Created by Pranjal Singh on 04/10/26.
//

import Foundation

final class AuthService
{
    static let shared = AuthService()
    
    private let apiClient = APIClient.shared
    private let tokenStore = TokenStore.shared
    
    private init(){}
    
    func login(email : String , password : String) async throws
    {
        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "username", value: email),
            URLQueryItem(name: "password", value: password)
        ]
        
        
        let body = components.percentEncodedQuery?.data(using: .utf8)
        
        let request = APIRequest(path: "/auth/login" , method: .POST , body: body ,headers: [
            "Content-Type" : "application/x-www-form-urlencoded"
        ] )
        
        let response : LoginResponse = try await apiClient.send(request)
        try tokenStore.save(token: response.accessToken)
    }
    
    func logOut()
    {
        tokenStore.deleteToken()
    }
    
    func hasStoredToken() -> Bool
    {
        return tokenStore.readToken() != nil
    }
    
   
}
