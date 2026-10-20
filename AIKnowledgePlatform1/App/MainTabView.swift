//
//  MainTabView.swift
//  AIKnowledgePlatform11
//
//  Created by Pranjal Singh on 15/10/26.
//

import SwiftUI

struct MainTabView : View {
    
    @State private var selectedTab = 0
    private let appState : AppState
    
    init(appState : AppState){
        self.appState = appState
    }
    
    var body: some View {
        
        TabView(selection: $selectedTab)
        {
            HomeView(openLibrary : {
                selectedTab = 1
            }, openConversations: {
                selectedTab = 2
            }
            )
                .tabItem{
                    Label("Home", systemImage: "house")
                }
                .tag(0)
            
            NotesView()
                .tabItem{
                    Label("Library", systemImage: "books.vertical")
                }
                .tag(1)
            
            ConversationsView()
                .tabItem{
                    Label("Conversations", systemImage: "bubble.left.and.bubble.right")
                }
                .tag(2)
            
            ProfileView(appState: appState)
                .tabItem{
                    Label("Profile" , systemImage: "person.circle")
                }
        }
    }
}
