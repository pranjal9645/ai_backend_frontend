//
//  NotesListResponse.swift
//  AIKnowledgePlatform11
//
//  Created by Pranjal Singh on 12/10/26.
//

import Foundation

struct NotesListResponse : Decodable
{
    let items : [Note]
    let total : Int
    let skip : Int
    let limit : Int
    let hasMore : Bool
    
    enum CodingKeys : String , CodingKey
    {
        case items
        case total
        case skip
        case limit
        case hasMore = "has_more"
    }
}
