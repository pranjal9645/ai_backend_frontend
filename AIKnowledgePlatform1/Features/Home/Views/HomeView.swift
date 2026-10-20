//
//  HomeView.swift
//  AIKnowledgePlatform11
//
//  Created by Pranjal Singh on 15/10/26.
//


import SwiftUI

struct HomeView : View {
    
    
    @StateObject private var viewModel = NotesViewModel()
    @State private var  isShowingCreateNote = false
    
    var openLibrary : () -> Void
    var openConversations: () -> Void

    
    private let columns = [
        GridItem(.flexible() , spacing: 12),
        GridItem(.flexible() , spacing: 12)
    ]
    
    var body: some View {
        
        NavigationStack{
            
            ScrollView
            {
                VStack(alignment : .leading , spacing: 24)
                {
                    header
                    askMindVaultCard
                    quickActions
                    recentKnowledge
                }
                .padding(.horizontal , 24)
                .padding(.top , 12)
                .padding(.bottom , 28)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationBarHidden(true)
            .refreshable {
                await viewModel.loadRecentNotes()
            }
            .task {
                await viewModel.loadRecentNotes()
            }
            .sheet(isPresented: $isShowingCreateNote){
                CreateNoteView(viewModel: viewModel)
            }
        }
    }
    
    
    private func sectionHeading(_ title : String , subtitle : String) -> some View
    {
        VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.title3.weight(.bold))

                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
    }
}

private extension HomeView
{
    var header : some View {
        
        HStack(alignment: .center){
            
            VStack(alignment: .leading, spacing: 6) {
                           Text("MINDVAULT")
                               .font(.caption.weight(.bold))
                               .tracking(2.5)
                               .foregroundStyle(.indigo)

                           Text("Your knowledge,\nwithin reach.")
                               .font(.system(size: 30, weight: .bold, design: .rounded))
                               .foregroundStyle(.primary)
                       }
            
            Spacer()
            
            Image(systemName: "brain.head.profile")
                .font(.system(size: 27, weight: .medium))
                .foregroundStyle(.white)
                .frame(width: 58, height: 58)
                .background(
                    LinearGradient(
                        colors: [.indigo , .purple] ,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ) , in: RoundedRectangle(cornerRadius: 19)
                )
                .shadow(color: .indigo.opacity(0.25), radius: 12 , y: 6)
                .accessibilityHidden(true)
        }
        .padding(.top , 8)
    }
}

private extension HomeView
{
    var askMindVaultCard: some View {
        
        VStack(alignment: .leading, spacing: 18) {
            
            HStack{
                           Image(systemName: "sparkles")
                               .font(.title2)

                           Spacer()

                           Text("AI KNOWLEDGE ASSISTANT")
                               .font(.system(size: 10, weight: .bold))
                               .tracking(1.2)
                }
                  .foregroundStyle(.white.opacity(0.9))
            
            VStack(alignment: .leading, spacing: 8) {
                          Text("Ask MindVault")
                              .font(.system(size: 25, weight: .bold, design: .rounded))
                              .foregroundStyle(.white)

                          Text("Get answers grounded in your saved knowledge.")
                              .font(.subheadline)
                              .foregroundStyle(.white.opacity(0.85))
                      }
            
            Button{
                openConversations()
            }label: {
                
                HStack(spacing: 10) {
                                    Text("Start a conversation")
                                    Image(systemName: "arrow.up.right")
                                }
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.indigo)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(.white, in: Capsule())
                
            }
            .buttonStyle(.plain)
        }
        .padding(22)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background{
            RoundedRectangle(cornerRadius: 28)
                .fill(
                    LinearGradient(
                        colors : [
                            Color(red: 0.31, green: 0.30, blue: 0.88),
                            Color(red: 0.53, green: 0.34, blue: 0.91),
                            Color(red: 0.38, green: 0.53, blue: 0.96)
                        ],
                        startPoint: .topLeading ,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(alignment : .topTrailing){
                        Circle()
                            .fill(.white.opacity(0.10))
                            .frame(width: 150, height: 150)
                            .offset(x: 45, y: -55)
                             .clipShape(
                                    RoundedRectangle(cornerRadius: 28)
                                )
                }
        }
        .shadow(color: .indigo.opacity(0.18), radius: 18 ,y: 18)
    }
}




private extension HomeView
{
    var quickActions : some View
    {
        VStack(alignment: .leading, spacing: 14) {
            
            sectionHeading("Quick actions", subtitle:  "Make more of your knowledge")
            
            LazyVGrid(columns: columns , spacing: 12)
            {
                quickActionCard(title: "Browse Library", subtitle: "Explore your notes", symbol: "books.vertical.fill", tint: .blue){
                    
                    openLibrary()
                }
                
                quickActionCard(title:  "Create a Note", subtitle:  "Save a new idea", symbol: "square.and.pencil", tint:  .purple){
                    viewModel.prepareForNewNote()
                    isShowingCreateNote = true
                }
            }
        }
    }
    
    
    func quickActionCard(title : String , subtitle : String , symbol : String , tint : Color  , action : @escaping () -> Void) -> some View
    {
        Button(action : action)
        {
            VStack(alignment: .leading, spacing: 12) {
                          Image(systemName: symbol)
                              .font(.title2.weight(.semibold))
                              .foregroundStyle(tint)
                              .frame(width: 44, height: 44)
                              .background(tint.opacity(0.12), in: RoundedRectangle(cornerRadius: 14))

                          VStack(alignment: .leading, spacing: 4) {
                              Text(title)
                                  .font(.subheadline.weight(.semibold))
                                  .foregroundStyle(.primary)

                              Text(subtitle)
                                  .font(.caption)
                                  .foregroundStyle(.secondary)
                                  .lineLimit(2)
                          }

                          Spacer(minLength: 0)
                      }
                      .frame(maxWidth: .infinity, minHeight: 112, alignment: .leading)
                      .padding(16)
                      .background(.background, in: RoundedRectangle(cornerRadius: 22))
                      .overlay {
                          RoundedRectangle(cornerRadius: 22)
                              .strokeBorder(.primary.opacity(0.05), lineWidth: 1)
                      }
                  }
                  .buttonStyle(.plain)
        }
}


private extension HomeView
{
    var recentKnowledge: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeading("Recent knowledge", subtitle: "Pick up where you left off")
            
            if viewModel.isLoadingRecentNotes && viewModel.recentNotes.isEmpty {
                HStack {
                    ProgressView()
                    Text("Loading your knowledge…")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(24)
                .background(.background, in: RoundedRectangle(cornerRadius: 20))
                
            } else if let error = viewModel.recentNotesErrorMessage,
                      viewModel.recentNotes.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "wifi.exclamationmark")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                    
                    Text(error)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                    
                    Button("Try again") {
                        Task {
                            await viewModel.loadRecentNotes()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
                .frame(maxWidth: .infinity)
                .padding(20)
                .background(.background, in: RoundedRectangle(cornerRadius: 20))
                
            } else if viewModel.recentNotes.isEmpty {
                ContentUnavailableView(
                    "Your library is waiting",
                    systemImage: "books.vertical",
                    description: Text("Create your first note to start building your knowledge.")
                )
                .padding(.vertical, 8)
                
            } else {
                VStack(spacing: 10) {
                    ForEach(viewModel.recentNotes) { note in
                        NavigationLink {
                            NoteDetailView(note: note , viewModel : viewModel, isDisabledMenu: true)
                        } label: {
                            HStack(spacing: 14) {
                                Image(systemName: "doc.text.fill")
                                    .font(.title3)
                                    .foregroundStyle(.indigo)
                                    .frame(width: 48, height: 52)
                                    .background(
                                        Color.indigo.opacity(0.10),
                                        in: RoundedRectangle(cornerRadius: 15)
                                    )
                                
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(note.title)
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(.primary)
                                        .lineLimit(1)
                                    
                                    Text(note.content)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(2)
                                    
                                    Text("Updated \(DateFormatterUtility.formattedNoteDate(note.updatedAt))")
                                        .font(.caption2)
                                        .foregroundStyle(.tertiary)
                                        .lineLimit(1)
                                }
                                
                                Spacer(minLength: 0)
                                
                                Image(systemName: "chevron.right")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(.tertiary)
                            }
                            .padding(14)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                .background,
                                in: RoundedRectangle(cornerRadius: 20)
                            )
                            .overlay {
                                RoundedRectangle(cornerRadius: 20)
                                    .strokeBorder(.primary.opacity(0.05), lineWidth: 1)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}


