//
//  ConversationCreateRequest.swift
//  AIKnowledgePlatform11
//
//  Created by Pranjal Singh on 18/10/26.
//

import Foundation

struct ConversationCreateRequest : Encodable
{
    let title : String?
    
    enum CodingKeys : String , CodingKey
    {
        case title
    }
}
