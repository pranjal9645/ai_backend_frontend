//
//  AuthViewModel.swift
//  AIKnowledgePlatform1
//
//  Created by Pranjal Singh on 04/10/26.
//

import Foundation
import Combine

@MainActor
final class AuthViewModel : ObservableObject
{
    @Published var email = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var errorMessage : String?
    
    private let authService = AuthService.shared
    private let appState : AppState
    
    init(appState : AppState)
    {
        self.appState = appState
    }
    
    func login() async
    {
        errorMessage = nil
        
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedEmail.isEmpty else
        {
            errorMessage = "Please enter your email."
            return
        }
        
        guard trimmedEmail.contains("@") , trimmedEmail.contains(".") else
        {
            errorMessage = "Please enter a valid email address."
            return
        }
        
        guard !password.isEmpty else {
            
            errorMessage = "Please enter your password."
            return
        }
        
        isLoading = true
        
        defer
        {
            isLoading = false
        }
        
        do{
            try await authService.login(email: trimmedEmail, password: password)
            appState.phase = .authenticated
        }catch let error as APIError
        {
           switch error
          {
           case .httpError(let statusCode , let message):
               
               switch statusCode
               {
               case 401:
                   errorMessage = "Incorrect email or password."
                   
               case 422:
                   errorMessage = message ?? "Please check your information."
                   
               case 500...599:
                   errorMessage = "Something went wrong on the server."
                   
               default :
                   errorMessage = message ?? "Unable to log in."
               }
            
           case .networkError:
               errorMessage = "Unable to connect to the server."
               
           case .invalidResponse:
               errorMessage = "The server returned an invalid response."
            
           case .decodingError:
               errorMessage = "Something went wrong while processing the response."
           case .encodingError:
               errorMessage = "Unable to prepare the login request."
           case .indvalidURL:
               errorMessage = "Unable to connect to the server."
           case .authenticationFailed:
               errorMessage = "Invalid Email or Password , Try Again."
           }
        }catch
        {
            errorMessage = "Something went wrong. Please try again."
        }
        
    }
    
    func logOut()
    {
        Task
        {
           do
           {
               try await authService.logout()
           }catch
           {
               // Local logout must still succeed
               // even if the server cannot be reached.
           }
            
            TokenStore.shared.deleteAllTokens()
            appState.phase = .unauthenticated
        }
    }
}
