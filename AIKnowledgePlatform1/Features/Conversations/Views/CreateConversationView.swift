//
//  CreateConversationView.swift
//  AIKnowledgePlatform11
//
//  Created by Pranjal Singh on 18/10/26.
//

import SwiftUI

struct CreateConversationView : View {
    
    @ObservedObject var viewModel : ConversationsViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var title = ""
    
    var body: some View {
       
        NavigationStack
        {
            Form
            {
                Section("Conversation Details") {
                     TextField("Title (optional)", text: $title)
                                    .textInputAutocapitalization(.sentences)
                                    .autocorrectionDisabled(false)
                    
                }
                
                if let errorMessage = viewModel.createErrorMessage
                {
                    Section{
                        Text(errorMessage)
                            .foregroundStyle(.red)
                    }
                }
                
                Section
                {
                    Button
                    {
                        Task
                        {
                            await viewModel.createConversation(title: title)
                        }
                        
                        if viewModel.didCreateConversation
                        {
                            dismiss()
                        }
                    }label: {
                        
                        HStack
                        {
                            Spacer()
                            
                            if viewModel.isCreating
                            {
                                ProgressView()
                            }else
                            {
                                Text("Create Conversation")
                                    .fontWeight(.semibold)
                            }
                            
                            Spacer()
                        }
                    }
                    .disabled(viewModel.isCreating)
                }
            }
            .navigationTitle("New Conversation")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar
            {
                ToolbarItem(placement: .topBarLeading){
                    Button("Cancel"){
                        dismiss()
                    }
                    .disabled(viewModel.isCreating)
                }
            }
        }
    }
}
