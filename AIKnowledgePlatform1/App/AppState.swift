//
//  AppState.swift
//  AIKnowledgePlatform1
//
//  Created by Pranjal Singh on 04/10/26.
//

import SwiftUI
import Combine

@MainActor
final class AppState : ObservableObject
{
    enum AppPhase
    {
        case loading
        case unauthenticated
        case authenticated
    }
    
    @Published var phase : AppPhase = .loading    
    private let tokenStore = TokenStore.shared
    private var authenticationObserver : NSObjectProtocol?
    
    init()
    {
        authenticationObserver = NotificationCenter.default.addObserver(forName: .authenticationExpired, object: nil, queue: .main){ [weak self] _ in
            
            Task { @MainActor [weak self] in
                             self?.handleAuthenticationExpired()
                         }
        }
    }
    
    deinit{
        if let authenticationObserver
        {
            NotificationCenter.default.removeObserver(authenticationObserver)
        }
    }
    
    func restoreSession()
    {
        if tokenStore.readAccessToken() != nil{
            phase = .authenticated
        }else
        {
            phase = .unauthenticated
        }
    }
    
    private func handleAuthenticationExpired()
    {
        phase = .unauthenticated
    }
}

