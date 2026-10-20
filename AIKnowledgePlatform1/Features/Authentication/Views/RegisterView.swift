//
//  RegisterView.swift
//  AIKnowledgePlatform11
//
//  Created by Pranjal Singh on 07/10/26.
//

import SwiftUI

struct RegisterView : View {
    
    @StateObject private var viewModel : RegisterViewModel
    @FocusState private var focusedField : Field?
    
    private enum Field
    {
        case name
        case email
        case password
        case confirmPassword
    }
    
    
    init(appState : AppState)
    {
        _viewModel = StateObject(wrappedValue: RegisterViewModel(appState: appState))
    }
    
    var body: some View {
        
        ScrollView
        {
            VStack(spacing : 0)
            {
                header
                
                form
                
                if let errorMessage = viewModel.errorMessage
                {
                    
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .frame(
                            maxWidth: .infinity,
                            alignment: .leading
                        )
                        .padding(.top, 12)
                }
                
                registerButton
                loginLink
            }
            .padding(.horizontal , 24)
            .padding(.top, 40)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            focusedField = nil
        }
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle("Create Account")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private extension RegisterView
{
    var header : some View
    {
        VStack(spacing : 12)
        {
            Image(systemName: "person.crop.circle.badge.plus")
                   .font(.system(size: 40))
                   .frame(width: 76, height: 76)
                   .background(
                       Color.accentColor.opacity(0.12)
                   )
                   .clipShape(
                       RoundedRectangle(
                           cornerRadius: 20
                       )
                   )
            
            Text("Create your account")
                .font(.system(size: 30 , weight: .bold))
                .multilineTextAlignment(.center)
            
            Text("Start your personalized learning journey.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom , 36)
    }
}

private extension RegisterView
{
    var form : some View
    {
        VStack(spacing : 20)
        {
            VStack(alignment: .leading, spacing: 8){
                
                Text("Name")
                    .font(.subheadline.weight(.medium))
                
                TextField("Your name" , text: $viewModel.name)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.name)
                    .autocorrectionDisabled(true)
                    .focused($focusedField , equals: .name)
                    .submitLabel(.next)
                    .onSubmit {
                        focusedField = .email
                    }
                    .disabled(viewModel.isLoading)
            }
            
            VStack(alignment: .leading, spacing: 8){
                
                Text("Email")
                        .font(.subheadline.weight(.medium))
                
                TextField("email@example.com" , text : $viewModel.email)
                               .textFieldStyle(.roundedBorder)
                              .textInputAutocapitalization(.never)
                              .keyboardType(.emailAddress)
                              .textContentType(.emailAddress)
                              .autocorrectionDisabled(true)
                              .focused($focusedField, equals: .email)
                              .submitLabel(.next)
                              .onSubmit {
                                  focusedField = .password
                              }
                              .disabled(viewModel.isLoading)
            }
            
            VStack(alignment: .leading, spacing: 8){
                
                Text("Password")
                    .font(.subheadline.weight(.medium))
                
                SecureField("Enter your password",text: $viewModel.password)
                          .textFieldStyle(.roundedBorder)
                          .textContentType(.oneTimeCode)
                          .focused($focusedField , equals: .password)
                          .submitLabel(.next)
                          .onSubmit {
                              focusedField = .confirmPassword
                          }
                          .disabled(viewModel.isLoading)
            }
            
            VStack(alignment: .leading, spacing: 8){
             
                Text("Confirm Password")
                              .font(.subheadline.weight(.medium))

                SecureField("Re-enter your password" , text: $viewModel.confirmPassword)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.oneTimeCode)
                    .focused($focusedField, equals: .confirmPassword)
                    .submitLabel(.done)
                    .onSubmit {
                        focusedField = nil
                        
                        Task
                        {
                            await viewModel.register()
                        }
                    }
                    .disabled(viewModel.isLoading)
            }
        }
    }
}

private extension RegisterView
{
    var registerButton : some View
    {
        VStack(spacing : 20)
        {
            Button
            {
                focusedField = nil
                
                Task
                {
                    await viewModel.register()
                }
            }label: {
                
                ZStack {
                    
                    Text("Create Account")
                        .font(.headline)
                        .opacity(
                            viewModel.isLoading ? 0 : 1
                        )
                    
                    if viewModel.isLoading {
                        
                        ProgressView()
                            .tint(.white)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 52)
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.isLoading || viewModel.cooldown.isActive)
            .padding(.top , 20)
            
            if viewModel.cooldown.isActive
            {
                Text("Please try again in \(viewModel.cooldown.remainingSeconds) seconds.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
            }
            
        }
    }
}

private extension RegisterView
{
    var loginLink : some View{
        
        Text("Already have an account? Log in")
             .font(.subheadline)
             .foregroundStyle(.secondary)
             .padding(.top, 24)
    }
}
