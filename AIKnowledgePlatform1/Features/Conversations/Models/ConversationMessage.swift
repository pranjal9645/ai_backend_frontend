//
//  ConversationMessage.swift
//  AIKnowledgePlatform11
//
//  Created by Pranjal Singh on 18/10/26.
//

import Foundation

struct ConversationMessage : Decodable , Identifiable
{
    let id : Int
    let role : String
    let content : String
    let createdAt : String
    
    enum CodingKeys : String , CodingKey
    {
        case id
        case role
        case content
        case createdAt = "created_at"
    }
    
}
