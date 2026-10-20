//
//  AssistantChatRequest.swift
//  AIKnowledgePlatform11
//
//  Created by Pranjal Singh on 18/10/26.
//

import Foundation

struct AssistantChatRequest : Encodable
{
    let conversationID : Int
    let message : String
    
    enum CodingKeys : String , CodingKey
    {
        case conversationID = "conversation_id"
        case message
    }
}
