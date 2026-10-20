//
//  NoteCreateRequest.swift
//  AIKnowledgePlatform11
//
//  Created by Pranjal Singh on 13/10/26.
//

import Foundation

struct NoteCreateRequest : Encodable
{
    let title : String
    let content : String
}
