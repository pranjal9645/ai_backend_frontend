//
//  ConversationDetailViewModel.swift
//  AIKnowledgePlatform11
//
//  Created by Pranjal Singh on 18/10/26.
//

import Foundation
import Combine

@MainActor

final class ConversationDetailViewModel : ObservableObject
{
     @Published private(set) var messages: [ConversationMessage] = []
     @Published private(set) var isLoading = false
     @Published private(set) var errorMessage: String?
    
    @Published private(set) var isSending = false
    @Published private(set) var sendErrorMessage: String?
    
    @Published private(set) var nextCursor : MessageCursor?
    @Published private(set) var hasMoreMessages = false
    @Published private(set) var isLoadingOlderMessages = false
    
    @Published private(set) var isLoadingNewerMessages = false
    
    @Published private(set) var answerSources: [Int: [AssistantSource]] = [:]
    
    private let conversationID : Int
    
    init(conversationID : Int)
    {
        self.conversationID = conversationID
    }
    
    
    func loadMessages() async{
        guard !isLoading else {return}
        
        isLoading  = true
        errorMessage = nil
        
        defer
        {
            isLoading = false
        }
        
        do
        {
            let page = try await ConversationService.shared.fetchMessages(conversationID: conversationID)
            
            messages = page.items
            nextCursor = page.nextCursor
            hasMoreMessages = page.hasMore
        }catch let error as APIError
        {
            switch error {
                        case .authenticationFailed:
                            errorMessage = "Your session has expired. Please log in again."

                        case .rateLimitExceeded:
                            errorMessage = "Too many requests. Please try again shortly."

                        case .serviceUnavailable:
                            errorMessage = "The service is temporarily unavailable."

                        case .networkError:
                            errorMessage = "Unable to connect. Check your internet connection."

                        case .httpError(_, let message):
                            errorMessage = message ?? "Unable to load conversation messages."

                        default:
                            errorMessage = "Something went wrong while loading messages."
                        }
        }catch
        {
            errorMessage = "Something went wrong while loading messages."
        }
    }
    
    
    func loadOlderMessages() async
    {
        guard hasMoreMessages else { return }
        
        guard !isLoadingOlderMessages else { return }
        
        guard let cursor = nextCursor else { return }
        
        isLoadingOlderMessages = true
        
        defer
        {
            isLoadingOlderMessages = false
        }
        
        do
        {
            let page = try await ConversationService.shared.fetchMessages(conversationID: conversationID , before: cursor)
            
            let existingIDs = Set(messages.map(\.id))
            
            let olderMessages = page.items.filter{
                !existingIDs.contains($0.id)
            }
            
            messages.insert(contentsOf: olderMessages, at: 0)
            nextCursor = page.nextCursor
            hasMoreMessages = page.hasMore
        }catch let error as APIError
        {
                     switch error {
                    case .authenticationFailed:
                        errorMessage = "Your session has expired. Please log in again."

                    case .rateLimitExceeded:
                        errorMessage = "Too many requests. Please try again shortly."

                    case .serviceUnavailable:
                        errorMessage = "The service is temporarily unavailable."

                    case .networkError:
                        errorMessage = "Unable to connect. Check your internet connection."

                    case .httpError(_, let message):
                        errorMessage = message ?? "Unable to load older messages."

                    default:
                        errorMessage = "Something went wrong while loading older messages."
                    }
        }catch
        {
            errorMessage = "Something went wrong while loading older messages."
        }
    }
    
    
    func loadNewerMessages() async
    {
        guard !isLoadingNewerMessages else {return}
        
        
        isLoadingNewerMessages = true
        
        defer
        {
            isLoadingNewerMessages = false
        }
    
        do
        {
            let page : ConversationMessagesPage
            
            if let latestMessage = messages.last {
                let cursor = MessageCursor(createdAt: latestMessage.createdAt, id: latestMessage.id)
                
                page = try await ConversationService.shared.fetchMessages(conversationID: conversationID , after : cursor)
                
            }else
            {
                // No existing messages means there is no "after" cursor.
                
                page = try await ConversationService.shared.fetchMessages(conversationID: conversationID)
            }
            
            let existingIDs = Set(messages.map(\.id))
            
            let newMessages = page.items.filter{
                !existingIDs.contains($0.id)
            }
            
            messages.append(contentsOf: newMessages)
            
        }catch let error as APIError
        {
            switch error {
                    case .authenticationFailed:
                        errorMessage = "Your session has expired. Please log in again."

                    case .rateLimitExceeded:
                        errorMessage = "Too many requests. Please try again shortly."

                    case .serviceUnavailable:
                        errorMessage = "The service is temporarily unavailable."

                    case .networkError:
                        errorMessage = "Unable to connect. Check your internet connection."

                    case .httpError(_, let message):
                        errorMessage = message ?? "Unable to load newer messages."

                    default:
                        errorMessage = "Something went wrong while loading newer messages."
                    }
        }catch
        {
            errorMessage = "Something went wrong while loading newer messages."
        }
    }
    
    func sendMessage(_ text : String) async {
        
        let trimmedMessage = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedMessage.isEmpty else
        {
            return
        }
        
        guard !isSending else
        {
            return
        }
        
        isSending = true
        sendErrorMessage = nil
        
        defer
        {
            isSending = false
        }
        
        do
        {
            let response = try await AssistantService.shared.sendMessage(conversationID: conversationID, message: trimmedMessage)
            
            try await waitForAssistantMessage(messageID: response.messageID)
            
            answerSources[response.messageID] = response.sources
            
            
        }catch let error as APIError
        {
            switch error {
                    case .authenticationFailed:
                        sendErrorMessage = "Your session has expired. Please log in again."

                    case .rateLimitExceeded:
                        sendErrorMessage = "Too many requests. Please try again shortly."

                    case .serviceUnavailable:
                        sendErrorMessage = "The service is temporarily unavailable."

                    case .networkError:
                        sendErrorMessage = "Unable to connect. Check your internet connection."

                    case .httpError(_, let message):
                        sendErrorMessage = message ?? "Unable to send your message."

                    default:
                        sendErrorMessage = "Something went wrong while sending your message."
                    }
            
        }catch
        {
            sendErrorMessage = "Something went wrong while sending your message."
        }
    }
    
    private func waitForAssistantMessage(messageID : Int , timeout : Duration = .seconds(30)) async throws {
        
        let clock = ContinuousClock()
        let deadline = clock.now + timeout
        
        while clock.now < deadline
        {
            try Task.checkCancellation()
            
            await loadNewerMessages()
            
            if messages.first(where: { $0.id == messageID && $0.role == "assistant"}) != nil
            {
                return
            }
            
            try await Task.sleep(for : .milliseconds(500))
        }
        
        throw APIError.invalidResponse
    }
}
