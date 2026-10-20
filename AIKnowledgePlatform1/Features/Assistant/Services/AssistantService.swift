//
//  AssistantService.swift
//  AIKnowledgePlatform11
//
//  Created by Pranjal Singh on 18/10/26.
//

import Foundation

final class AssistantService
{
    static let shared = AssistantService()
    
    private init (){}
    
    func sendMessage(conversationID : Int , message : String) async throws -> AssistantChatResponse
    {
        let payload = AssistantChatRequest(conversationID: conversationID, message: message)
        
        let body : Data
        
        do
        {
            body = try JSONEncoder().encode(payload)
        }catch
        {
            throw APIError.encodingError
        }
        
        let request = APIRequest(path: "assistant/chat", method: .POST , body: body , headers: [
            "Content-Type" : "application/json"
        ] ,authenticationPolicy: .required, unauthorizedRetryPolicy: .refreshAccessTokenOnce)
        
        return try await APIClient.shared.send(request)
    }
    
}
