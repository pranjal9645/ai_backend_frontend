//
//  ConversationMessagesPage.swift
//  AIKnowledgePlatform11
//
//  Created by Pranjal Singh on 19/10/26.
//

import Foundation

struct ConversationMessagesPage : Decodable
{
    let items : [ConversationMessage]
    let nextCursor : MessageCursor?
    let hasMore : Bool
    
    enum CodingKeys : String  , CodingKey
    {
        case items
        case nextCursor = "next_cursor"
        case hasMore = "has_more"
    }
}

struct MessageCursor : Decodable
{
    let createdAt : String
    let id : Int
    
    enum CodingKeys : String , CodingKey
    {
        case createdAt = "created_at"
        case id
    }
}
