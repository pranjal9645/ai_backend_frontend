//
//  AuthModels.swift
//  AIKnowledgePlatform1
//
//  Created by Pranjal Singh on 04/10/26.
//

import Foundation
struct LoginResponse : Decodable
{
    let accessToken : String
    let tokenType : String
    
    enum CodingKeys: String , CodingKey
    {
        case accessToken = "access_token"
        case tokenType = "token_type"
    }
}
