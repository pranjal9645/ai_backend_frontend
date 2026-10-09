//
//  RegisterViewModel.swift
//  AIKnowledgePlatform11
//
//  Created by Pranjal Singh on 07/10/26.
//

import Foundation
import Combine

@MainActor

final class RegisterViewModel : ObservableObject
{
    @Published var name = ""
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    
    @Published var isLoading = false
    @Published var errorMessage : String?
    
    private let authService = AuthService.shared
    private let appState : AppState
    
    init(appState : AppState)
    {
        self.appState = appState
    }
    
    func register() async
    {
        guard !isLoading else
        {
          return
        }
        
        errorMessage = nil
        
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedName.isEmpty else
        {
            errorMessage = "Please enter your name."
            return
        }
        
        guard trimmedName.count >= 2 else
        {
            errorMessage = "Your name must atleast contain 2 characters."
            return
        }
        
        guard !trimmedEmail.isEmpty else
        {
            errorMessage = "Please enter your email."
            return
        }
        
        guard trimmedEmail.contains("@"),
              trimmedEmail.contains(".") else {
            errorMessage = "Please enter a valid email address."
            return
        }
        
        guard !password.isEmpty else
        {
            errorMessage = "Please enter a password."
            return
        }
        
        guard password.count >= 8 else
        {
            errorMessage = "Password must be at least 8 characters."
            return
        }
        
        guard !confirmPassword.isEmpty else {
                  errorMessage = "Please confirm your password."
                  return
              }
        
        guard password == confirmPassword else {
                   errorMessage = "Passwords do not match."
                   return
        }
        
        
        isLoading = true
        
        defer{
            isLoading = false
        }
        
        do
        {
            try await authService.register(name: name, email: email, password: password)
            
            appState.phase = .authenticated
        }catch let error as APIError
        {
            switch error {
            case .indvalidURL:
                errorMessage = "Unable to connect to the server."
            case .invalidResponse:
                errorMessage =   "The server returned an invalid response."
            case .httpError(let statusCode, let message):
                
                switch statusCode
                {
                case 400:
                    errorMessage = message ?? "Unable to create your account."
                
                case 409:
                    errorMessage = message ??  "An account with this email already exists."
                    
                case 422:
                    errorMessage = message ?? "Please check your information."
                    
                case 500...599:
                    errorMessage = "Something went wrong on the server."
                    
                default:
                    errorMessage = message ?? "Unable to create your account."
                }
                
            case .decodingError:
                errorMessage =  "Something went wrong while processing the response."
            case .encodingError:
                errorMessage =  "Unable to prepare the registration request."
            case .networkError:
                errorMessage =  "Unable to connect to the server."
                
            case .authenticationFailed:
                errorMessage = "Failed to create an account."
            }
        }catch
        {
           errorMessage = "Something went wrong. Please try again."
        }


    }
}
