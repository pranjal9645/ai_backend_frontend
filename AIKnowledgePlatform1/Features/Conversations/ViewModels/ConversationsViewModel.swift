//
//  ConversationsViewModel.swift
//  AIKnowledgePlatform11
//
//  Created by Pranjal Singh on 18/10/26.
//

import Foundation
import Combine

@MainActor
final class ConversationsViewModel : ObservableObject
{
        // MARK: - Fetch
    
        @Published private(set) var conversations: [Conversation] = []
        @Published private(set) var isLoading = false
        @Published private(set) var hasLoaded = false
        @Published private(set) var errorMessage: String?
    
        // MARK: - Create
    
       @Published private(set) var isCreating = false
       @Published private(set) var createErrorMessage: String?
       @Published private(set) var didCreateConversation = false
      
      //MARK: - Delete
    
       @Published private(set) var isDeleting = false
       @Published  var deleteErrorMessage: String?
       @Published private(set) var didDeleteConversation = false
      // MARK: - Load Conversations
    
    
    func loadConversations() async
    {
        guard !isLoading else
        {
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        defer
        {
            isLoading = false
            hasLoaded = true
        }
        
        do
        {
            conversations = try await ConversationService.shared.fetchConversations()
        }catch let error as APIError
        {
           handleLoadError(error)
        }catch
        {
            errorMessage = "Something went wrong. Please try again."
        }
    }
    
    func createConversation(title : String? = nil) async
    {
        guard !isCreating else
        {
            return
        }
        
        let trimmedTitle = title?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard trimmedTitle?.count ?? 0  <= 255 else
        {
            createErrorMessage = "The title cannot exceed 255 characters."
            didCreateConversation = false
            return
        }
        
        isCreating = true
        createErrorMessage = nil
        didCreateConversation = false
        
        defer
        {
            isCreating = false
        }
        
        do
        {
            let conversation = try await ConversationService.shared.createConversation(title: trimmedTitle)
            
            if !conversations.contains(where: {$0.id == conversation.id})
            {
                conversations.insert(conversation, at: 0)
            }
            
            didCreateConversation = true
        }catch let error as APIError
        {
            handleCreateError(error)
            
        }catch
        {
            createErrorMessage = "Something went wrong. Please try again."
        }
    }
    
    func deleteConversation(conversationID : Int) async
    {
        
        guard !isDeleting else
        {
            return
        }
        
        isDeleting = true
        didDeleteConversation = false
        deleteErrorMessage = nil
        
        defer
        {
            isDeleting = false
            
        }
        
        do
        {
            let _ : ConversationDeleteResponse = try await ConversationService.shared.deleteConversation(conversationID: conversationID)
            
            conversations.removeAll{
                $0.id == conversationID
            }
            didDeleteConversation = true
        }catch let error as APIError
        {
           handleDeleteError(error)
        }catch
        {
            deleteErrorMessage = "Something went wrong. Please try again."
        }
    }
    
    // MARK: - Load Error Handling
    private func handleLoadError(_ error: APIError) {
            switch error {
            case .invalidURL:
                errorMessage = "Unable to connect to the server."

            case .invalidResponse:
                errorMessage = "The server returned an invalid response."

            case .httpError(let statusCode, let message):
                switch statusCode {
                case 401:
                    errorMessage = "Your session has expired. Please log in again."
                case 403:
                    errorMessage = "You don't have permission to access conversations."
                case 422:
                    errorMessage = message ?? "The request was invalid."
                case 500...599:
                    errorMessage = "The server encountered a problem. Please try again."
                default:
                    errorMessage = message ?? "Unable to load conversations."
                }

            case .authenticationFailed:
                errorMessage = "Your session has expired. Please log in again."

            case .rateLimitExceeded(_, let message):
                errorMessage = message

            case .serviceUnavailable:
                errorMessage = "The service is temporarily unavailable. Please try again."

            case .decodingError:
                errorMessage = "We couldn't read the conversations from the server."

            case .encodingError:
                errorMessage = "Unable to prepare the request."

            case .networkError:
                errorMessage = "Couldn't connect to the server. Check your connection."
            }
        }
    
    // MARK: - Create Error Handling
    
       private func handleCreateError(_ error: APIError) {
           switch error {
           case .invalidURL:
               createErrorMessage = "Unable to connect to the server."

           case .invalidResponse:
               createErrorMessage = "The server returned an invalid response."

           case .httpError(let statusCode, let message):
               switch statusCode {
               case 401:
                   createErrorMessage = "Your session has expired. Please log in again."
               case 403:
                   createErrorMessage = "You don't have permission to create conversations."
               case 422:
                   createErrorMessage = message ?? "Please check the conversation title."
               case 500...599:
                   createErrorMessage = "The server encountered a problem. Please try again."
               default:
                   createErrorMessage = message ?? "Unable to create the conversation."
               }

           case .authenticationFailed:
               createErrorMessage = "Your session has expired. Please log in again."

           case .rateLimitExceeded(_, let message):
               createErrorMessage = message

           case .serviceUnavailable:
               createErrorMessage = "The service is temporarily unavailable. Please try again."

           case .decodingError:
               createErrorMessage = "The server response could not be read."

           case .encodingError:
               createErrorMessage = "Unable to prepare the conversation request."

           case .networkError:
               createErrorMessage = "Couldn't connect to the server. Check your connection."
           }
       }
   
    
    private func handleDeleteError(_ error : APIError)
    {
        switch error
     {
        case .authenticationFailed:
            deleteErrorMessage = "Your session has expired. Please log in again."
            
        case .rateLimitExceeded(_, let message):
            deleteErrorMessage = message
            
        case .serviceUnavailable(let message):
            deleteErrorMessage = message
            
        case .httpError(_, let message):
            deleteErrorMessage = message ?? "Unable to delete this conversation. Please try again."
            
        case .networkError:
            deleteErrorMessage = "Network error. Check your connection and try again."
            
        default:
            deleteErrorMessage = "Something went wrong while deleting this conversation."
      }
    }
}
