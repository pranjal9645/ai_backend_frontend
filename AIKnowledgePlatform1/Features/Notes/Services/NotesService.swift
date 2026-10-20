//
//  NotesService.swift
//  AIKnowledgePlatform11
//
//  Created by Pranjal Singh on 12/10/26.
//

import Foundation

final class NotesService
{
    static let shared = NotesService()
    
    private init(){}
    
    func fetchNotes() async throws ->  NotesListResponse
    {
        let request = APIRequest(path: "notes/" , method: .GET , headers: [
            "Content-Type" : "application/json"
        ], authenticationPolicy: .required, unauthorizedRetryPolicy: .refreshAccessTokenOnce)
        
        return try await APIClient.shared.send(request)
    }
    
    func createNote(title : String , content : String) async throws -> Note
    {
        let payload = NoteCreateRequest(title: title, content: content)
        
        let body : Data
        
        do
        {
            body = try JSONEncoder().encode(payload)
        }catch
        {
            throw APIError.encodingError
        }
        
        let request = APIRequest(path: "notes/", method : .POST, body: body ,
                                 headers: [
                                    "Content-Type": "application/json"
                                 ],authenticationPolicy: .required, unauthorizedRetryPolicy: .refreshAccessTokenOnce)
        
        return try await APIClient.shared.send(request)
    }
    
    func updateNote(id : Int , title : String? = nil , content : String? = nil) async throws -> Note
    {
        guard title != nil || content != nil else
        {
            throw APIError.encodingError
        }
        
        let payload = NoteUpdateRequest(title: title, content: content)
        
        let body : Data
        
        do
        {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.sortedKeys]
            body = try encoder.encode(payload)
        }catch
        {
            throw APIError.encodingError
        }
        
        let request = APIRequest(path :"notes/\(id)" , method: .PATCH , body: body , headers: [
            "Content-Type" : "application/json"
        ] , authenticationPolicy: .required , unauthorizedRetryPolicy: .refreshAccessTokenOnce)
        
        return try await APIClient.shared.send(request)
    }
    
    func deleteNote(id : Int) async throws -> NoteDeleteResponse
    {
        let request = APIRequest(path : "notes/\(id)" , method: .DELETE , authenticationPolicy: .required , unauthorizedRetryPolicy: .refreshAccessTokenOnce)
        
        return try await APIClient.shared.send(request)
    }
}
