//
//  EditNoteView.swift
//  AIKnowledgePlatform11
//
//  Created by Pranjal Singh on 13/10/26.
//

import SwiftUI

struct EditNoteView : View
{
    @ObservedObject var viewModel : NotesViewModel
    
    let note : Note
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var title: String
    @State private var content: String
    
    init(note : Note , viewModel : NotesViewModel)
    {
        self.note = note
        self.viewModel = viewModel
        
        _title = State(initialValue: note.title)
        _content = State(initialValue: note.content)
    }
    
    
    private var trimmedTitle: String {
           title.trimmingCharacters(in: .whitespacesAndNewlines)
       }

       private var trimmedContent: String {
           content.trimmingCharacters(in: .whitespacesAndNewlines)
       }

       private var titleChanged: Bool {
           trimmedTitle != note.title
       }

       private var contentChanged: Bool {
           trimmedContent != note.content
       }
     
    private var hasChanges : Bool
    {
        titleChanged || contentChanged
    }
    
    private var canSave : Bool
    {
        hasChanges && !trimmedTitle.isEmpty && !trimmedContent.isEmpty && !viewModel.isUpdating
    }
    
    var body : some View
    {
        NavigationStack{
            
            Form
            {
                Section("Note Details")
                {
                    TextField("Note Title", text: $title)
                        .textInputAutocapitalization(.sentences)
                }
                
                           Section("Content") {
                                TextEditor(text: $content)
                                    .frame(minHeight: 220)
                            }
                
                if let error = viewModel.updateErrorMessage
                {
                    Section
                    {
                        Label(error , systemImage: "exclamationmark.circle")
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("Edit Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar{
                ToolbarItem(placement: .cancellationAction){
                    Button
                    {
                        dismiss()
                    }label: {
                       
                        Text("Cancel")
                            .bold()
                    }
                }
                
                ToolbarItem(placement : .confirmationAction){
                    Button{
                        saveChanges()
                    }label: {
                        
                        if viewModel.isUpdating
                        {
                            ProgressView()
                        }else
                        {
                            Text("Save")
                        }
                    }
                    .disabled(!canSave)
                }
            }
            .task {
                viewModel.prepareForEditing()
            }
        }
    }
    
    private func saveChanges()
    {
        let updatedTitle = titleChanged ? trimmedTitle : nil
        let updatedContent = contentChanged ? trimmedContent : nil
        
        Task
        {
            await viewModel.updateNote(id: note.id , title: updatedTitle , content: updatedContent)
            
            if viewModel.didUpdateNote
            {
                dismiss()
            }
        }
        
    }
}
