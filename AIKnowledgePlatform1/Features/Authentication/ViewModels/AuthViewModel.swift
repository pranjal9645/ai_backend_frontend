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
        guard !email.isEmpty , !password.isEmpty else
        {
            errorMessage = "Please enter your email and password."
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do
        {
            try await authService.login(email: email, password: password)
            appState.phase = .authenticated
        }catch
        {
            errorMessage =  "Login failed."
        }
        
        isLoading = false
    }
    
    func logOut()
    {
        authService.logOut()
        appState.phase = .unauthenticated
    }
}
