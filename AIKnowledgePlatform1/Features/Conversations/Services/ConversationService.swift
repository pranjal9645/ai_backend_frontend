//
//  ConversationService.swift
//  AIKnowledgePlatform11
//
//  Created by Pranjal Singh on 18/10/26.
//

import Foundation

final class ConversationService
{
    static let shared = ConversationService()
    
    private init() {}
    
    // MARK: - Fetch Conversations
    
    func fetchConversations() async throws -> [Conversation]
    {
        let request = APIRequest(path : "conversations" , method: .GET , authenticationPolicy: .required , unauthorizedRetryPolicy: .refreshAccessTokenOnce)
        
        return try await APIClient.shared.send(request)
    }
    
    // MARK: - Create Conversation
    
    func createConversation(title : String? = nil) async throws -> Conversation
    {
        let body : Data
        
        do
        {
            body = try JSONEncoder().encode(ConversationCreateRequest(title: title))
        }catch
        {
            throw APIError.encodingError
        }
        
        let request = APIRequest(path : "conversations" , method: .POST , body: body , headers: [
            "Content-Type" : "application/json"
        ] , authenticationPolicy: .required , unauthorizedRetryPolicy: .refreshAccessTokenOnce)
        
        return try await APIClient.shared.send(request)
    }
    
    
    //MARK: Delete Conversation
    
    func deleteConversation(conversationID : Int) async throws -> ConversationDeleteResponse
    {
        let request = APIRequest(path : "conversations/\(conversationID)" , method: .DELETE ,authenticationPolicy: .required , unauthorizedRetryPolicy: .refreshAccessTokenOnce)
        
        return try await APIClient.shared.send(request)
    }
    
    // MARK: - Fetch Messages
    
    func fetchMessages(conversationID : Int , limit : Int = 10 , before cursor : MessageCursor? = nil , after newerCursor : MessageCursor? = nil) async throws -> ConversationMessagesPage
    {
        
        // The backend does not allow both cursor directions.
        
        guard cursor == nil || newerCursor == nil else
        {
            throw APIError.invalidResponse
        }
        
        var queryItems = [
            URLQueryItem(name: "limit", value: String(limit))
            
        ]
        
        if let cursor
        {
            queryItems.append(URLQueryItem(name:"before_created_at", value: cursor.createdAt))
            
            queryItems.append(URLQueryItem(name:"before_id", value: String(cursor.id)))
        }
        
        if let newerCursor
        {
            queryItems.append(URLQueryItem(name:"after_created_at", value: newerCursor.createdAt))
            
            queryItems.append(URLQueryItem(name: "after_id", value: String(newerCursor.id)))
        }
        
        let request = APIRequest(path : "conversations/\(conversationID)/messages" , method: .GET , queryItems: queryItems , authenticationPolicy: .required , unauthorizedRetryPolicy: .refreshAccessTokenOnce)
        
        return try await APIClient.shared.send(request)
    }
}
