//
//  NotesView.swift
//  AIKnowledgePlatform11
//
//  Created by Pranjal Singh on 12/10/26.
//

import SwiftUI

struct NotesView : View {
    
    @StateObject private var  viewModel = NotesViewModel()
    @State private var  isShowingCreateNote = false
    @State private var noteToEdit : Note?
    @State private var noteToDelete : Note?
    @State private var searchText = ""
    @State private var actualQuery = ""
    
    @State private var sortOrder : NoteSortOrder = .newest
    
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
                    errorView(message : errorMessage)
                }else if viewModel.notes.isEmpty
                {
                    emptyView
                }
                else
                {
                    notesList
                }
            }
            .navigationTitle("My Notes")
            .navigationBarTitleDisplayMode(.large)
            .task {
                await viewModel.loadNotes()
            }
            .toolbar
            {
                ToolbarItem(placement: .topBarTrailing){
                    
                    Button
                    {
                        viewModel.prepareForNewNote()
                        isShowingCreateNote = true
                    }label: {
                        
                        Image(systemName: "plus")
                    }.accessibilityLabel("Create note")
                }
                
                ToolbarItem(placement: .topBarLeading){
                    Menu
                    {
                        Button{
                            sortOrder = .newest
                        }label: {
                            if sortOrder == .newest
                            {
                                Label("Recently Updated", systemImage: "checkmark")
                            }else
                            {
                                Text("Recently Updated")
                            }
                        }
                        
                        Button
                        {
                            sortOrder = .oldest
                        }label: {
                            
                            if sortOrder == .oldest
                            {
                                Label("Oldest Updated", systemImage: "checkmark")
                            }else
                            {
                                Text("Oldest Updated")
                            }
                        }
                    }label: {
                        Image(systemName: "arrow.up.arrow.down")
                    }
                    .accessibilityLabel("Sort notes")
                }
            }
            .sheet(isPresented: $isShowingCreateNote){
                CreateNoteView(viewModel: viewModel)
            }
            .sheet(item: $noteToEdit){ note in
                
                EditNoteView(note: note, viewModel: viewModel)
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
    
    private enum NoteSortOrder
    {
        case newest
        case oldest
    }
    
    private var filteredNotes: [Note] {
        let query = actualQuery

        let matchingNotes = viewModel.notes.filter { note in
            guard !query.isEmpty else {
                return true
            }

            return note.title.localizedCaseInsensitiveContains(query)
                || note.content.localizedCaseInsensitiveContains(query)
        }


        func parseDate(_ value: String) -> Date? {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(secondsFromGMT: 0)

            let formats = [
                "yyyy-MM-dd HH:mm:ss.SSSSSS",
                "yyyy-MM-dd'T'HH:mm:ss.SSSSSS",
                "yyyy-MM-dd HH:mm:ss",
                "yyyy-MM-dd'T'HH:mm:ss"
            ]

            for format in formats {
                formatter.dateFormat = format

                if let date = formatter.date(from: value) {
                    return date
                }
            }

            return nil
        }

        return matchingNotes.sorted { first, second in
            let firstDate = parseDate(first.updatedAt)
            let secondDate = parseDate(second.updatedAt)

            switch (firstDate, secondDate) {
            case let (firstDate?, secondDate?):
                
                switch sortOrder {
                case .newest:
                    return firstDate > secondDate
                case .oldest:
                    return firstDate < secondDate
                }
            case (_?, nil):
                return true
            case (nil, _?):
                return false
            case (nil, nil):
                return false
            }
        }
    }
}

// MARK: - Loading

private extension NotesView
{
    var loadingView: some View
    {
        ProgressView("Loading your notes...")
            .frame(maxWidth : .infinity , maxHeight : .infinity)
    }
}
// MARK: Empty State

private extension NotesView
{
    var emptyView : some View
    {
        ContentUnavailableView( "No Notes Yet", systemImage: "note.text", description: Text( "Your notes will appear here once you create them."))
    }
}

// MARK: Error State

private extension NotesView
{
    func errorView(message : String) -> some View
    {
        ContentUnavailableView{
            Label("Couldn't Load Notes", systemImage: "exclamationmark.triangle")
        }description: {
            Text(message)
                .padding(6)
        }actions: {
            
            Button("Try again"){
                Task{
                    await viewModel.loadNotes()
                }
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

private extension NotesView
{
    var notesList : some View
    {
        List{
            
            Section{
                HStack
                {
                    Text(actualQuery.isEmpty ? "\(viewModel.notes.count) notes" : "Showing \(filteredNotes.count) of \(viewModel.notes.count) notes")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .listRowSeparator(.hidden)
            }
            if filteredNotes.isEmpty && !actualQuery.isEmpty
            {
                ContentUnavailableView.search(text: searchText)
            }else
            {
                ForEach(filteredNotes){ note in
                    
                    NavigationLink{
                        NoteDetailView(note: note , viewModel: viewModel, onEdit: { selectedNote in
                            
                            viewModel.prepareForEditing()
                            noteToEdit = selectedNote
                        },
                        onDelete: { selectedNote in
                            
                            await viewModel.deleteNote(id: selectedNote.id)
                            return viewModel.didDeleteNote
                        },
                        isDisabledMenu: false
                    )
                    }label:{
                        
                        VStack(alignment: .leading, spacing : 8)
                        {
                            Text(note.title)
                                .font(.headline)
                                .foregroundStyle(.primary)
                            
                            Text(note.content.trimmingCharacters(in: .whitespacesAndNewlines))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                                .truncationMode(.tail)
                            Text("Updated: \(DateFormatterUtility.formattedNoteDate(note.updatedAt))")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                        .padding(.vertical , 6)
                        
                    }
                    .buttonStyle(.plain)
                    .swipeActions(edge: .trailing , allowsFullSwipe: false){
                        
                        Button{
                            viewModel.prepareForEditing()
                            noteToEdit = note
                        }label: {
                            Label("Edit" , systemImage: "pencil")
                        }
                        .tint(.blue)
                        
                        
                        Button(role : .destructive)
                        {
                            noteToDelete = note
                        }label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                    
                }
            }
        }
        .listStyle(.insetGrouped)
        .refreshable {
            guard actualQuery.isEmpty else
            {
                return
            }
            await viewModel.loadNotes()
        }
        .scrollDismissesKeyboard(.immediately)
        .searchable(text: $searchText, prompt: "Search Notes")
        .task(id : searchText) {
            
            let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if query.isEmpty
            {
                actualQuery = query
                return
            }

            try? await Task.sleep(for : .milliseconds(300))
            
            guard !Task.isCancelled else {return}
            
            actualQuery = query
        }
        .alert( "Delete this note?", isPresented: Binding(
            get: { noteToDelete != nil },
            set: { isPresented in
                if !isPresented {
                    noteToDelete = nil
                }
            }
        )
        ){
            Button("Cancel" , role: .cancel)
            {
                noteToDelete = nil
            }
            
            Button("Delete" , role: .destructive)
            {
                guard let note = noteToDelete else {return}
                
                Task
                {
                    await viewModel.deleteNote(id: note.id)
                    
                    if viewModel.didDeleteNote
                    {
                        noteToDelete = nil
                    }
                }
            }
        }message: {
            Text("This action cannot be undone.")
        }
    }
}
#Preview {
    NotesView()
}


