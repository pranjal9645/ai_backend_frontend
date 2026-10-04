//
//  RootView.swift
//  AIKnowledgePlatform1
//
//  Created by Pranjal Singh on 04/10/26.
//

import SwiftUI

struct RootView : View {
    
    @EnvironmentObject var appState : AppState
    
    var body: some View {
        Group
        {
            switch appState.phase
          {
            case .unauthenticated:
                
                LoginView(appState: appState)
                
            case .authenticated:
                Text("Main App")
          }
        }
    }
}
