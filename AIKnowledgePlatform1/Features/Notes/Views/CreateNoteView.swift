//
//  CreateNoteView.swift
//  AIKnowledgePlatform11
//
//  Created by Pranjal Singh on 13/10/26.
//

import SwiftUI

struct CreateNoteView : View {
    
    @ObservedObject var viewModel : NotesViewModel
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var title = ""
    @State private var content = ""
    
    private var canSave : Bool
    {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !viewModel.isCreating
    }
    
    
    
    var body: some View {
        
        NavigationStack{
            
            Form{
                Section("Note Details"){
                    
                    TextField("Note title", text: $title)
                        .textInputAutocapitalization(.sentences)
                }
                    
                    Section("Content")
                    {
                        TextEditor(text: $content)
                            .frame(minHeight: 220)
                    }

                
                if let error = viewModel.createErrorMessage
                {
                    Section
                    {
                        Label( error, systemImage : "exclamationmark.circle")
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("New Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar
            {
                ToolbarItem(placement: .cancellationAction){
                    Button{
                        dismiss()
                    }label: {
                        Text("Cancel")
                            .bold()
                    }
                    .disabled(viewModel.isCreating)
                }
                  
                ToolbarItem(placement: .confirmationAction){
                    Button
                    {
                        Task
                        {
                            await viewModel.createNote(title: title, content: content)
                            
                            if viewModel.didCreateNote
                            {
                                dismiss()
                            }
                        }
                    }label: {
                    
                        if viewModel.isCreating
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
        }
    }
}

#Preview {
    CreateNoteView(viewModel: NotesViewModel())
}
