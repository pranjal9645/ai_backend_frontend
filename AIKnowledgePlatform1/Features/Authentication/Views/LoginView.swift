//
//  LoginView.swift
//  AIKnowledgePlatform1
//
//  Created by Pranjal Singh on 04/10/26.
//

import SwiftUI

struct LoginView : View {
    @StateObject var viewModel : AuthViewModel
    
    init(appState : AppState){
        _viewModel = StateObject(wrappedValue: AuthViewModel(appState: appState))
    }
    var body: some View {
        
                         VStack(spacing: 16)
                       {
                             
                          TextField("Email", text: $viewModel.email)
                                .textFieldStyle(.roundedBorder)
                                .textInputAutocapitalization(.never)
                                 .keyboardType(.emailAddress)
                          
                             SecureField("Password" , text: $viewModel.password)
                                 .textFieldStyle(.roundedBorder)
                             
                             Button
                             {
                                 Task
                                 {
                                     await viewModel.login()
                                 }
                             }label: {
                                 if viewModel.isLoading
                                 {
                                     ProgressView()
                                 }else
                                 {
                                     Text("Login")
                                 }
                             }.buttonStyle(.borderedProminent)
                                
                             if let errorMessage = viewModel.errorMessage{
                                 Text(errorMessage)
                                     .foregroundStyle(.red)
                             }
                        
                         }.padding()
    }
}

