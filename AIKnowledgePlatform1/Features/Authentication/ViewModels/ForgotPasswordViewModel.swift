//
//  ForgotPasswordViewModel.swift
//  AIKnowledgePlatform11
//
//  Created by Pranjal Singh on 07/10/26.
//

import Foundation
import Combine

@MainActor
final class ForgotPasswordViewModel : ObservableObject
{
    @Published var email = ""
    @Published var isLoading  = false
    @Published var errorMessage : String?
    @Published var didSendRequest = false
    
    let cooldown = RateLimitCooldown()
    private var cancellables = Set<AnyCancellable>()
    
    private let authService = AuthService.shared
    
    init()
    {
        cooldown.objectWillChange
            .sink{[weak self] _ in
                
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
    
    func sendResetLink() async
    {
        guard !isLoading , !cooldown.isActive else
        {
            return
        }
        
        errorMessage = nil
        
            let trimmedEmail = email.trimmingCharacters(
                   in: .whitespacesAndNewlines
               )

               guard !trimmedEmail.isEmpty else {
                   errorMessage = "Please enter your email."
                   return
               }

               guard trimmedEmail.contains("@"),
                     trimmedEmail.contains(".") else {
                   errorMessage = "Please enter a valid email address."
                   return
               }

               isLoading = true

               defer {
                   isLoading = false
               }
          
        do
        {
            try await authService.forgotPassword(email: trimmedEmail)
            email = ""
            didSendRequest = true
        }catch let error as APIError
        {
                         switch error {

                      case .httpError( _ , let message):
                          errorMessage = message
                              ?? "Unable to send the reset link."

                      case .networkError:
                          errorMessage =
                              "Unable to connect to the server."
                      
                         case .rateLimitExceeded(retryAfter: let retryAfter, message: let message):
                             
                             errorMessage = message
                             cooldown.start(seconds: retryAfter)
                            
                         case .serviceUnavailable(message: let message):
                             errorMessage = message
                             

                      default:
                          errorMessage =
                              "Something went wrong. Please try again."
                      }
        }catch
        {
            errorMessage =  "Something went wrong. Please try again."
        }
    }

}
