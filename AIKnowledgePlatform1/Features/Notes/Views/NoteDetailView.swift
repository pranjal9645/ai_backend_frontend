//
//  NoteDetailView.swift
//  AIKnowledgePlatform11
//
//  Created by Pranjal Singh on 13/10/26.
//

import SwiftUI

struct NoteDetailView : View {
    
    let note : Note
    let viewModel : NotesViewModel
    var onEdit : ((Note) -> Void)? = nil
    var onDelete : ((Note) async  -> Bool)? = nil
    let isDisabledMenu : Bool
    
    
    @Environment(\.dismiss) private var dismiss
    @State private var isShowingDeleteConfirmation = false
    
    var body: some View {
        
        ScrollView
        {
            VStack(alignment: .leading , spacing: 20){
                
                Text(note.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .frame(maxWidth : .infinity , alignment: .leading)
                
                VStack(alignment: .leading , spacing: 6)
                {
                    Label("Last updated",systemImage: "clock")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                     
                    
                    Text(DateFormatterUtility.formattedNoteDate(note.updatedAt))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Divider()
                
                Text(note.content)
                    .font(.body)
                    .frame(maxWidth: .infinity , alignment: .leading)
                    .textSelection(.enabled)
            }
            .padding()
        }
        .navigationTitle("Note")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar{
            ToolbarItem(placement: .topBarTrailing){
                
                Menu
                {
                    Button{
                        onEdit?(note)
                    }label: {
                        HStack(spacing: 7){
                            Image(systemName: "pencil")
                                .tint(.blue)
                            Text("Edit")
                                .fontWeight(.medium)
                               
                            
                        }
                    }
                    .accessibilityLabel("Edit note")
                    
                    Button(role : .destructive){
                        isShowingDeleteConfirmation = true
                    }label: {
                        HStack(spacing : 7)
                        {
                            Image(systemName: "trash")
                            Text("Delete")
                                .fontWeight(.medium)
                        }
                    }
                    .accessibilityLabel("Delete Note")
                }label: {
                    Image(systemName: "ellipsis")
                }
            }
        }
        .disabled(isDisabledMenu)
        
        .alert("Delete this note?",isPresented: $isShowingDeleteConfirmation)
        {
            Button("Cancel", role: .cancel) {}
            
            Button("Delete" , role: .destructive)
            {
                Task
                {
                    guard let onDelete else
                    {
                        return
                    }
                    
                    let didDelete = await onDelete(note)
                    
                    if didDelete
                    {
                        dismiss()
                    }
                }
            }
        }message: {
            Text("This action cannot be undone.")
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
