//
//  AIKnowledgePlatform1App.swift
//  AIKnowledgePlatform1
//
//  Created by Pranjal Singh on 04/10/26.
//

import SwiftUI

@main
struct AIKnowledgePlatform1App: App
{
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            
            RootView()
                .environmentObject(appState)
        }
    }
}
