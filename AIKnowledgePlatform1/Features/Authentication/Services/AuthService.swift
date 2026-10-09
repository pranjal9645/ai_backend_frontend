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
        ]  , authenticationPolicy: .none , unauthorizedRetryPolicy: .never)
        
        let response : TokenResponse = try await apiClient.send(request)
        try tokenStore.saveAccessToken(response.accessToken)
        try tokenStore.saveRefreshToken(response.refreshToken)
    }
    
    
    func hasStoredToken() -> Bool
    {
        return tokenStore.readAccessToken() != nil
    }
    
    
    
    func forgotPassword(email : String) async throws
    {
        let forgotPasswordRequest = ForgotPasswordRequest(email: email)
        
        let body = try JSONEncoder().encode(forgotPasswordRequest)
        
        let request = APIRequest(path: "/auth/forgot-password" , method: .POST , body: body,
                     headers: [
                        "Content-Type" : "application/json"
                     ]
                                 , authenticationPolicy: .none , unauthorizedRetryPolicy: .never)
        let _ : ForgotPasswordResponse = try await apiClient.send(request)
    }
    
    func register(name : String , email : String , password : String) async throws
    {
        
        let registerRequest = RegisterRequest(name : name , email: email, password: password)
        
        let body = try JSONEncoder().encode(registerRequest)
        
        let request = APIRequest(path: "/users/" , method: .POST , body: body , headers: [
            "Content-Type" : "application/json"
        ] , authenticationPolicy: .none , unauthorizedRetryPolicy: .never)
        
        let response : RegisterResponse = try await apiClient.send(request)
        
        try tokenStore.saveAccessToken(response.accessToken)
        try tokenStore.saveRefreshToken(response.refreshToken)
    }
    
    func resetPassword(token : String , newPassword : String) async throws
    {
        let resetRequest = ResetPasswordRequest(token: token, newPassword: newPassword)
        
        let body = try JSONEncoder().encode(resetRequest)
        
        let request = APIRequest(path: "/auth/reset-password" , method: .POST , body: body , headers: [
            "Content-Type" : "application/json"]
                                 , authenticationPolicy: .none , unauthorizedRetryPolicy: .never)
        
        let _ : ResetPasswordResponse = try await apiClient.send(request)
    }
    
    func logout() async throws
    {
        guard let refreshToken = tokenStore.readRefreshToken() else {
            tokenStore.deleteAllTokens()
            return
        }
        
        let body : [String : String] = [
            "refresh_token" : refreshToken
        ]
        
        let bodyData = try JSONEncoder().encode(body)
        
        let request = APIRequest(path: "/auth/logout" , method: .POST, body: bodyData , headers: [
            "Content-Type" : "application/json"
        ] , authenticationPolicy: .none , unauthorizedRetryPolicy: .never)
        
        let _ : LogoutResponse = try await apiClient.send(request)
    }
   
}
