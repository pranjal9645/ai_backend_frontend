//
//  AssistantChatResponse.swift
//  AIKnowledgePlatform11
//
//  Created by Pranjal Singh on 18/10/26.
//

import Foundation

struct AssistantChatResponse: Decodable {
    
    let conversationID : Int
    let messageID : Int
    let answer : String
    let sources : [AssistantSource]
    
    enum CodingKeys : String , CodingKey
    {
              case conversationID = "conversation_id"
              case messageID = "message_id"
              case answer
              case sources
    }
}

struct AssistantSource: Decodable, Identifiable {
    
       let noteID: Int
       let chunkID: Int
       let chunkIndex: Int
       let content: String
    
      var id : Int
     {
        chunkID
     }
     
     enum CodingKeys: String, CodingKey {
            case noteID = "note_id"
            case chunkID = "chunk_id"
            case chunkIndex = "chunk_index"
            case content
        }
}
