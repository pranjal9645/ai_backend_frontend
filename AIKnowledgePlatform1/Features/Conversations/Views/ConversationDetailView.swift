//
//  ConversationDetailView.swift
//  AIKnowledgePlatform11
//
//  Created by Pranjal Singh on 18/10/26.
//


import SwiftUI

struct ConversationDetailView: View {

    @StateObject private var viewModel: ConversationDetailViewModel
    
    @State private var messageText = ""
    @FocusState private var isMessageFieldFocused: Bool
    @State private var isLoadingOlderMessages = false

    
    private let conversation : Conversation
    
    init(conversation : Conversation) {
        _viewModel = StateObject(
            wrappedValue: ConversationDetailViewModel(
                conversationID: conversation.id
            )
        )
        
        self.conversation = conversation
    }

    var body: some View {
     
        VStack(spacing : 0)
        {
            Group {
                if viewModel.isLoading && viewModel.messages.isEmpty {
                    ProgressView("Loading messages...")
                } else if let errorMessage = viewModel.errorMessage,
                          viewModel.messages.isEmpty {
                    ContentUnavailableView(
                        "Unable to Load Messages",
                        systemImage: "exclamationmark.bubble",
                        description: Text(errorMessage)
                    )
                } else if viewModel.messages.isEmpty {
                    ContentUnavailableView(
                        "No Messages Yet",
                        systemImage: "bubble.left.and.bubble.right",
                        description: Text("This conversation doesn't have any messages yet.")
                    )
                } else {
                    
                    
                    ScrollViewReader { proxy in
                        ScrollView {
                            LazyVStack(alignment: .leading, spacing: 24) {
                                
                                // Detect when the top of the message list is reached.
                                Color.clear
                                    .frame(height : 1)
                                    .onAppear{
                                        
                                        guard !isLoadingOlderMessages else
                                        {
                                            return
                                        }
                                        
                                        isLoadingOlderMessages = true
                                        Task
                                        {
                                            await viewModel.loadOlderMessages()
                                            isLoadingOlderMessages = false
                                        }
                                    }
                                ForEach(viewModel.messages) { message in
                                    
                                    if message.role.lowercased() == "user" {
                                        HStack {
                                            Spacer(minLength: 48)

                                            Text(message.content)
                                                .textSelection(.enabled)
                                                .padding(.horizontal, 16)
                                                .padding(.vertical, 12)
                                                .background(
                                                    Color.indigo.opacity(0.14),
                                                    in: RoundedRectangle(cornerRadius: 20)
                                                )
                                        }
                                        .id(message.id)
                                    } else {
                                        VStack(alignment: .leading, spacing: 12) {
                                            HStack(spacing: 8) {
                                                Image(systemName: "sparkle")
                                                    .font(.subheadline)
                                                    .foregroundStyle(.indigo)

                                                Text("MindVault")
                                                    .font(.subheadline.weight(.semibold))
                                                    .foregroundStyle(.indigo)
                                            }

                                            Text(message.content)
                                                .textSelection(.enabled)
                                                .frame(
                                                    maxWidth: .infinity,
                                                    alignment: .leading
                                                )
                                            
                                    if let sources = viewModel.answerSources[message.id] , !sources.isEmpty
                                    {
                                        DisclosureGroup
                                        {
                                            VStack(alignment : .leading , spacing : 12)
                                            {
                                                ForEach(sources){ source in
                                                            
                                                 VStack(alignment: .leading, spacing: 6){
                                                                
                                                    Text("Note ID: \(source.noteID)")
                                                            .font(.subheadline.weight(.semibold))
                                                     
                                                    Text(source.content)
                                                         .font(.footnote)
                                                         .foregroundStyle(.secondary)
                                                         .textSelection(.enabled)
                                                     
                                                     Text("Chunk \(source.chunkIndex)")
                                                         .font(.caption)
                                                         .foregroundStyle(.secondary)

                                                            }
                                                 .frame(maxWidth : .infinity , alignment : .leading)
                                                 .padding(10)
                                                 .background(Color.secondary.opacity(0.08) , in : RoundedRectangle(cornerRadius: 10)
                                                 )
                                                        }
                                                    }
                                            .padding(.top , 8)
                                        }label:
                                        {
                                            Label( "Sources (\(sources.count))", systemImage: "book.closed")
                                                .font(.subheadline.weight(.medium))
                                                .foregroundStyle(.indigo)
                                        }
                                    }
                                        }
                                        .frame(maxWidth : .infinity , alignment: .leading)
                                        .id(message.id)
                                    }
                                    
                                
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 20)
                        }
                        .onChange(of: viewModel.messages.count) { oldCount, newCount in
                            
                            guard newCount > oldCount else { return }
                            
                            guard !isLoadingOlderMessages else { return }
                            
                            
                            guard let lastMessage = viewModel.messages.last else {
                                return
                            }

                            withAnimation(.easeOut(duration: 0.2)) {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                        .onAppear {
                            guard let lastMessage = viewModel.messages.last else {
                                return
                            }

                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                    
                }
            }
            
            Divider()
            HStack(spacing: 12) {
                TextField("Ask about your knowledge...", text: $messageText, axis: .vertical)
                    .lineLimit(1...5)
                    .focused($isMessageFieldFocused)
                
                Button {
                    
                    let message = messageText
                    
                    Task
                    {
                        await viewModel.sendMessage(message)
                        
                        if viewModel.sendErrorMessage == nil
                        {
                            messageText = ""
                            isMessageFieldFocused = false
                        }
                    }
                } label: {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 42, height: 42)
                        .background(
                            Color.indigo,
                            in: Circle()
                        )
                }
                .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
        }
        .navigationTitle(conversation.title ?? "Conversation")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadMessages()
        }
        .refreshable {
            await viewModel.loadMessages()
        }
        .contentShape(Rectangle())
        .onTapGesture {
            isMessageFieldFocused = false
        }
    }
}



