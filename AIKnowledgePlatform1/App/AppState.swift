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
        case unauthenticated
        case authenticated
    }
    
    @Published var phase : AppPhase = .unauthenticated
}

