//
//  Note.swift
//  AIKnowledgePlatform11
//
//  Created by Pranjal Singh on 12/10/26.
//

import Foundation

struct Note : Decodable , Identifiable
{
    let id: Int
    let title: String
    let content: String
    let userID: Int
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys : String , CodingKey
    {
        case id
        case title
        case content
        case userID = "user_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
