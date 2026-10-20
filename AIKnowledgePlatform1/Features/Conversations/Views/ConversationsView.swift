//
//  ConversationsView.swift
//  AIKnowledgePlatform11
//
//  Created by Pranjal Singh on 18/10/26.
//

import SwiftUI

struct ConversationsView : View {
    
    @StateObject private var viewModel = ConversationsViewModel()
    @State private var isShowingCreateConversation = false
    @State private var conversationToDelete : Conversation?
    
    var body: some View {
        
       NavigationStack
        {
            Group
            {
                if viewModel.isLoading && !viewModel.hasLoaded
                {
                    loadingView
                }else if let errorMessage = viewModel.errorMessage
                {
                    errorView(message: errorMessage)
                }else if viewModel.conversations.isEmpty
                {
                    emptyView
                }else
                {
                    conversationsList
                }
            }
            .navigationTitle("Conversations")
            .navigationBarTitleDisplayMode(.large)
            .toolbar
            {
                ToolbarItem(placement: .topBarTrailing){
                    
                    Button{
                        isShowingCreateConversation = true
                    }label: {
                        
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Create conversation")
                }
            }
            .task {
                await viewModel.loadConversations()
            }
            
            .sheet(isPresented: $isShowingCreateConversation){
                
                CreateConversationView(viewModel: viewModel)
            }
            
            .alert(
                "Unable to Delete Note",
                isPresented: Binding(
                    get: { viewModel.deleteErrorMessage != nil },
                    set: { if !$0 { viewModel.deleteErrorMessage = nil } }
                )
            ) {
                Button("OK", role: .cancel) {
                    viewModel.deleteErrorMessage = nil
                }
            } message: {
                Text(viewModel.deleteErrorMessage ?? "")
            }
        }
    }
    
    private var loadingView : some View
    {
        ProgressView("Loading conversations...")
            .frame(maxWidth: .infinity , maxHeight: .infinity)
    }
    
    private var emptyView : some View
    {
        ContentUnavailableView {
                   Label(
                       "No Conversations Yet",
                       systemImage: "bubble.left.and.bubble.right"
                   )
               } description: {
                   Text("Create a conversation to start using your AI assistant.")
               } actions: {
                   Button("New Conversation") {
                       isShowingCreateConversation = true
                   }
                   .buttonStyle(.borderedProminent)
            }
    }
    
    private func errorView(message : String) -> some View
    {
        ContentUnavailableView {
                    Label(
                        "Couldn't Load Conversations",
                        systemImage: "exclamationmark.triangle"
                    )
                } description: {
                    Text(message)
                } actions: {
                    Button("Try Again") {
                        Task {
                            await viewModel.loadConversations()
                        }
                    }
                    .buttonStyle(.borderedProminent)
        }
    }
    
    private var conversationsList : some View
    {
        List(viewModel.conversations){ conversation in
            
            NavigationLink{
                ConversationDetailView(conversation: conversation)
            }label: {
                VStack(alignment: .leading, spacing: 6) {
                    
                    Text( conversation.title?
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                        .isEmpty == false
                          ? conversation.title! : "Untitled Conversation"
                    )
                    .font(.headline)
                    .lineLimit(1)
                    
                    Text("Updated\(DateFormatterUtility.formattedNoteDate(conversation.updatedAt))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                .padding(.vertical , 4)
            }
            .swipeActions{
                Button(role : .destructive){
                    conversationToDelete = conversation
                }label: {
                    
                    Label("Delete", systemImage: "trash")
                }
            }
        }
        .listStyle(.insetGrouped)
        .refreshable {
            await viewModel.loadConversations()
        }
        .alert("Delete this Conversation?" , isPresented: Binding(
            get:{ conversationToDelete != nil
                
            },
            set: { isPresented in
                
                if !isPresented
                {
                    conversationToDelete = nil
                }
                
            }
        )){
            
            Button("Cancel" , role: .cancel)
            {
                conversationToDelete = nil
            }
            
            Button("Delete", role: .destructive){
                
                guard let conversation = conversationToDelete else
                {
                    return
                }
                
                Task
                {
                    await viewModel.deleteConversation(conversationID: conversation.id)
                    if viewModel.didDeleteConversation
                    {
                        conversationToDelete = nil
                    }
            
                    
                }
            }
        }
    }
}

