//
//  RootView.swift
//  AIKnowledgePlatform1
//
//  Created by Pranjal Singh on 04/10/26.
//

import SwiftUI

struct RootView : View {
    
    @EnvironmentObject var appState : AppState
    @State private var resetPasswordToken : String?
    
    var body: some View {
        Group
        {
            switch appState.phase
          {
            case .loading:
                
                ProgressView()
                
            case .unauthenticated:
                
                NavigationStack
                {
                    LoginView(appState: appState)
                        .navigationDestination(isPresented: resetPasswordDestinationIsPresented){
                            if let token = resetPasswordToken
                            {
                                ResetPasswordView(token: token)
                            }
                        }
                }
                
            case .authenticated:
                    MainTabView(appState: appState)
                    
              
          }
        }.task {
            appState.restoreSession()
            
        }
        
        .onOpenURL{ url in
            
            handleDeepLink(url)
        }
    }
    
    private var resetPasswordDestinationIsPresented: Binding<Bool> {
        Binding(
            get: {
                appState.phase == .unauthenticated && resetPasswordToken != nil
            },
            set: { isPresented in
                // Clear the token when the reset screen is dismissed.
                if !isPresented {
                    resetPasswordToken = nil
                }
            }
        )
    }
    
    private func handleDeepLink(_ url : URL)
    {
        guard url.scheme == "aiknowledge" else
        {
            return
        }
        
        guard url.host == "reset-password" else
        {
            return
        }
        
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else
        {
            return
        }
        
        guard let token = components.queryItems?.first(where: {$0.name == "token"})?.value else
        {
            return
        }
        
        guard !token.isEmpty else
        {
            return
        }
        
        resetPasswordToken = token
        
    }
}
