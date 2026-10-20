//
//  NotesViewModel.swift
//  AIKnowledgePlatform11
//
//  Created by Pranjal Singh on 12/10/26.
//

import Foundation
import Combine

@MainActor
final class NotesViewModel : ObservableObject
{
    //MARK: READ
    @Published private(set) var notes : [Note] = []
    @Published private(set) var isLoading  = false
    @Published private(set) var hasLoaded = false
    @Published private(set) var errorMessage : String?
    
    
    @Published private(set) var recentNotes: [Note] = []
    @Published private(set) var isLoadingRecentNotes = false
    @Published private(set) var recentNotesErrorMessage: String?
    
    //MARK: CREATE
    @Published private(set) var isCreating = false
    @Published private(set) var createErrorMessage: String?
    @Published private(set) var didCreateNote = false
    
    //MARK: UPDATE
    @Published private(set) var isUpdating = false
    @Published private(set) var updateErrorMessage: String?
    @Published private(set) var didUpdateNote = false
    
    //MARK: DELETE
    @Published var isDeleting = false
    @Published var deleteErrorMessage: String?
    @Published var didDeleteNote = false
    
    
    func loadNotes() async
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
            let response = try await NotesService.shared.fetchNotes()
            
            notes = response.items
        }catch let error as APIError
        {
            handleError(error)
        }catch
        {
            errorMessage = "Something went wrong. Please try again."
        }
    }
    
    private func handleError( _ error : APIError)
    {
        switch error {
        case .invalidURL:
            errorMessage = "Unable to connect to the server."
        case .invalidResponse:
            errorMessage = "The server returned an invalid response."
        case .httpError(let statusCode, let message):
            switch statusCode
            {
            case 401:
                errorMessage = "Your session has expired. Please log in again."
            case 403:
                errorMessage = "You don't have permission to access these notes."
            case 404:
                errorMessage = "The notes resource could not be found."
            case 429:
                errorMessage = message ?? "Too many requests. Please try again later."
            case 500...599:
                errorMessage = "The server encountered a problem. Please try again."
            default:
                errorMessage = message ?? "Unable to load your notes."
            }
        case .authenticationFailed:
            errorMessage = "Your session has expired. Please log in again."
        case .rateLimitExceeded( _ , let message):
            errorMessage = message
        case .serviceUnavailable:
            errorMessage = "The service is temporarily unavailable. Please try again."
        case .decodingError:
            errorMessage = "We couldn't read your notes from the server."
        case .encodingError:
            errorMessage = "Unable to prepare the request."
        case .networkError:
            errorMessage = "Couldn't connect to the server. Check your connection."
        }
    }
    
    func createNote(title : String , content : String) async
    {
        guard !isCreating else {return}
        
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedContent = content.trimmingCharacters(
             in: .whitespacesAndNewlines
         )
        
        guard !trimmedTitle.isEmpty else
        {
            createErrorMessage = "Please enter a title."
            didCreateNote = false
            return
        }
        
        guard !trimmedContent.isEmpty else
        {
            createErrorMessage = "Please enter some content."
                didCreateNote = false
            return
        }
        
        isCreating = true
        createErrorMessage = nil
        
        defer
        {
            isCreating = false
        }
        
        do
        {
            let createdNote = try await NotesService.shared.createNote(title: trimmedTitle, content: trimmedContent)
            
            if !notes.contains(where: {$0.id == createdNote.id})
            {
                notes.insert(createdNote, at: 0)
            }
            
            didCreateNote = true
            
        }catch let error as APIError
        {
           handleCreateError(error)
        }catch
        {
            createErrorMessage = "Something went wrong. Please try again."
        }
    }
    
    
    func updateNote(id : Int , title : String? = nil , content : String? = nil) async
    {
        guard !isUpdating else { return }
        
        let trimmedTitle = title?.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        let trimmedContent = content?.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard trimmedTitle != nil || trimmedContent != nil else {
            updateErrorMessage = "There are no changes to save."
            didUpdateNote = false
            return
        }
        
        if let trimmedTitle, trimmedTitle.isEmpty {
             updateErrorMessage = "The title cannot be empty."
             didUpdateNote = false
             return
         }
        
        
        if let trimmedContent, trimmedContent.isEmpty {
               updateErrorMessage = "The content cannot be empty."
               didUpdateNote = false
               return
           }
        
            isUpdating = true
           updateErrorMessage = nil
           didUpdateNote = false
        
        defer
        {
            isUpdating = false
        }
        
        do
        {
            let updatedNote = try await NotesService.shared.updateNote(id: id , title: trimmedTitle , content: trimmedContent)
            
            if let index = notes.firstIndex(where: {$0.id == id})
            {
                notes[index] = updatedNote
            }else
            {
               await loadNotes()
            }
            
            didUpdateNote = true
        }catch let error as APIError
        {
            handleUpdateError(error)
        }catch
        {
            updateErrorMessage = "Something went wrong. Please try again."
        }
    }
    
    
    func deleteNote(id : Int) async
    {
        guard !isDeleting else {return}
        
        isDeleting = true
        deleteErrorMessage = nil
        didDeleteNote = false
        
        defer
        {
            isDeleting = false
        }
        
        do
        {
            _ = try await NotesService.shared.deleteNote(id: id)
            
            notes.removeAll(where: {$0.id == id})
            didDeleteNote = true
        }catch
        {
            handleDeleteError(error)
        }
    }
    
    
    func loadRecentNotes() async {
        guard !isLoadingRecentNotes else { return }

        isLoadingRecentNotes = true
        recentNotesErrorMessage = nil

        defer {
            isLoadingRecentNotes = false
        }

        do {
            let response = try await NotesService.shared.fetchNotes()

            recentNotes = Array(
                response.items
                    .sorted { first, second in
                        let firstDate = parseDate(first.updatedAt)
                        let secondDate = parseDate(second.updatedAt)

                        switch (firstDate, secondDate) {
                        case let (firstDate?, secondDate?):
                            return firstDate > secondDate
                        case (_?, nil):
                            return true
                        default:
                            return false
                        }
                    }
                    .prefix(3)
            )
        } catch let error as APIError {
            switch error {
            case .authenticationFailed:
                recentNotesErrorMessage = "Your session has expired. Please log in again."
            case .rateLimitExceeded(_, let message):
                recentNotesErrorMessage = message
            case .serviceUnavailable:
                recentNotesErrorMessage = "The service is temporarily unavailable."
            case .networkError:
                recentNotesErrorMessage = "Couldn't connect. Check your connection."
            case .httpError(_, let message):
                recentNotesErrorMessage = message ?? "Couldn't load your recent notes."
            default:
                recentNotesErrorMessage = "Couldn't load your recent notes."
            }
        } catch {
            recentNotesErrorMessage = "Something went wrong. Please try again."
        }
    }
    
    private func handleCreateError(_ error : APIError)
    {
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
                    createErrorMessage = "You don't have permission to create notes."
                case 404:
                    createErrorMessage = "The notes endpoint could not be found."
                case 422:
                    createErrorMessage = message ?? "Please check the note details."
                case 500...599:
                    createErrorMessage = "The server encountered a problem. Please try again."
                default:
                    createErrorMessage = message ?? "Unable to create your note."
                }

            case .authenticationFailed:
                createErrorMessage = "Your session has expired. Please log in again."

            case .rateLimitExceeded(_, let message):
                createErrorMessage = message

            case .serviceUnavailable:
                createErrorMessage = "The service is temporarily unavailable. Please try again."

            case .networkError:
                createErrorMessage = "Couldn't connect to the server. Check your connection."

            case .decodingError:
                createErrorMessage = "The server response could not be read."

            case .encodingError:
                createErrorMessage = "Unable to prepare your note."
            }
    }
    
    private func handleUpdateError(_ error : APIError)
    {
        switch error {
           case .invalidURL:
               updateErrorMessage = "Unable to connect to the server."

           case .invalidResponse:
               updateErrorMessage = "The server returned an invalid response."

           case .httpError(let statusCode, let message):
               switch statusCode {
               case 400:
                   updateErrorMessage = "You must atleast provide one field."
               case 401:
                   updateErrorMessage = "Your session has expired. Please log in again."
               case 403:
                   updateErrorMessage = "You don't have permission to edit this note."
               case 404:
                   updateErrorMessage = "This note could not be found."
               case 422:
                   updateErrorMessage = message ?? "Please check the note details."
               case 500...599:
                   updateErrorMessage = "The server encountered a problem. Please try again."
               default:
                   updateErrorMessage = message ?? "Unable to update your note."
               }

           case .authenticationFailed:
               updateErrorMessage = "Your session has expired. Please log in again."

           case .rateLimitExceeded(_, let message):
               updateErrorMessage = message

           case .serviceUnavailable:
               updateErrorMessage = "The service is temporarily unavailable. Please try again."

           case .networkError:
               updateErrorMessage = "Couldn't connect to the server. Check your connection."

           case .decodingError:
               updateErrorMessage = "The server response could not be read."

           case .encodingError:
               updateErrorMessage = "Unable to prepare your changes."
           }
    }
    
    private func handleDeleteError(_ error : Error)
    {
        if let apiError = error as? APIError {
               switch apiError {
               case .authenticationFailed:
                   deleteErrorMessage = "Your session has expired. Please log in again."

               case .rateLimitExceeded(_, let message):
                   deleteErrorMessage = message

               case .serviceUnavailable(let message):
                   deleteErrorMessage = message

               case .httpError(_, let message):
                   deleteErrorMessage = message ?? "Unable to delete this note. Please try again."

               case .networkError:
                   deleteErrorMessage = "Network error. Check your connection and try again."

               default:
                   deleteErrorMessage = "Something went wrong while deleting this note."
               }
           } else {
               deleteErrorMessage = "Something went wrong while deleting this note."
           }
    }
    
    func prepareForNewNote()
    {
        guard !isCreating else
        {
            return
        }
        
        createErrorMessage = nil
        didCreateNote = false
    }
    
    func prepareForEditing()
    {
        guard !isUpdating else {return}
        
        updateErrorMessage = nil
        didUpdateNote = false
    }
    
    private func  parseDate(_ value: String) -> Date? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)

        let formats = [
            "yyyy-MM-dd HH:mm:ss.SSSSSS",
            "yyyy-MM-dd'T'HH:mm:ss.SSSSSS",
            "yyyy-MM-dd HH:mm:ss",
            "yyyy-MM-dd'T'HH:mm:ss"
        ]

        for format in formats {
            formatter.dateFormat = format

            if let date = formatter.date(from: value) {
                return date
            }
        }

        return nil
    }

}
