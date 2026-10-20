//
//  ResetPasswordViewModel.swift
//  AIKnowledgePlatform11
//
//  Created by Pranjal Singh on 08/10/26.
//

import Foundation
import Combine

@MainActor
final class ResetPasswordViewModel : ObservableObject
{
    @Published var password = ""
    @Published var confirmPassword = ""
    
    @Published var isLoading = false
    @Published var errorMessage : String?
    @Published var didResetPassword = false
    
    let cooldown = RateLimitCooldown()
    private var cancellables = Set<AnyCancellable>()
    
    private let token : String
    
    init(token : String)
    {
        self.token = token
        
        cooldown.objectWillChange
            .sink{ [weak self] _ in
                
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
    
    func resetPassword() async
    {
        guard !isLoading  , !cooldown.isActive else
        {
            return
        }
        
        errorMessage = nil
        
        guard !password.isEmpty else
        {
            errorMessage = "Please enter your new password."
            return
        }
        
        guard password.count >= 8 else
        {
            errorMessage =  "Password must be at least 8 characters."
            return
        }
        
        guard !confirmPassword.isEmpty else
        {
            errorMessage =  "Please confirm your new password."
            return
        }
        
        guard password == confirmPassword else
        {
            errorMessage =  "Passwords do not match."
            return
        }
        
        isLoading = true
        
        defer
        {
            isLoading = false
        }
        
        do
        {
            try await AuthService.shared.resetPassword(token: token, newPassword: password)
            password = ""
            confirmPassword = ""
            didResetPassword = true
        }catch let error as APIError
        {
            switch error {
            case .invalidURL:
                errorMessage =  "Unable to connect to the server."
            case .invalidResponse:
                errorMessage =   "The server returned an invalid response."
            case .httpError(let statusCode, let message):
                
                 switch statusCode
                 {
                    case 400:
                         errorMessage =    message ?? "This reset link is invalid."
                    
                    case 401:
                     errorMessage =    message ?? "This reset link is invalid or has expired."
                     
                 case 404:
                     errorMessage =  message ?? "This reset link is no longer valid."
                     
                 case 422:
                     errorMessage =    message ?? "Please check your password."
                    
                 case 429:
                     errorMessage = message ?? "Too many requests . Please try again later."
                     
                 case 500...599:
                     errorMessage =  "Something went wrong on the server."
                     
                 default :
                     errorMessage =  message ?? "Unable to reset your password."
                 }
                
            case .authenticationFailed:
                errorMessage = "Your session could not be authenticated."
            case .decodingError:
                errorMessage = "Something went wrong while processing the response."
            case .encodingError:
                errorMessage = "Unable to prepare the reset request."
            case .networkError:
                errorMessage =  "Unable to connect to the server."
                
            case .rateLimitExceeded(retryAfter:  let retryAfter , message: let message):
                errorMessage = message
                cooldown.start(seconds: retryAfter)
            case .serviceUnavailable(message: let message):
                errorMessage = message
            }
        }catch
        {
            errorMessage =  "Something went wrong. Please try again."
        }
    }
    
}
