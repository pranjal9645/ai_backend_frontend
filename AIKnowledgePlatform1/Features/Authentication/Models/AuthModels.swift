//
//  AuthModels.swift
//  AIKnowledgePlatform1
//
//  Created by Pranjal Singh on 04/10/26.
//

import Foundation
nonisolated
struct TokenResponse : Decodable , Sendable
{
    let accessToken : String
    let refreshToken : String
    let tokenType : String
    
    enum CodingKeys: String , CodingKey
    {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case tokenType = "token_type"
    }
}

nonisolated
struct ForgotPasswordRequest : Encodable , Sendable
{
    let email : String
}

nonisolated
struct ForgotPasswordResponse : Decodable  , Sendable {}

nonisolated
struct RegisterRequest: Encodable  , Sendable {
    let name : String
    let email: String
    let password: String
}

nonisolated
struct UserResponse : Decodable , Sendable
{
    let id : Int
    let name : String
    let email : String
}

nonisolated
struct RegisterResponse : Decodable , Sendable
{
    let user : UserResponse
    let accessToken : String
    let refreshToken : String
    let tokenType : String
    
    enum CodingKeys : String , CodingKey
    {
        case user
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case tokenType = "token_type"
    }
}

nonisolated
struct ResetPasswordRequest : Encodable , Sendable
{
    let token : String
    let newPassword : String
    
    enum CodingKeys : String , CodingKey
    {
        case token
        case newPassword = "new_password"
    }
}

nonisolated
struct ResetPasswordResponse: Decodable, Sendable {

    let message: String
}

nonisolated
struct LogoutResponse : Decodable , Sendable
{
    let message : String
}



