//
//  LoginView.swift
//  AIKnowledgePlatform1
//
//  Created by Pranjal Singh on 04/10/26.
//

import SwiftUI

struct LoginView : View {
    @StateObject var viewModel : AuthViewModel
    @FocusState private var focusedField : Field?
    private let appState : AppState
    
    private enum Field
    {
        case email
        case password
    }
    
    init(appState : AppState){
        self.appState = appState
        _viewModel = StateObject(wrappedValue: AuthViewModel(appState: appState))
    }
    var body: some View {
        
        ScrollView{
            
            VStack(spacing : 0){
                
                header
                form
                if let errorMessage = viewModel.errorMessage
                {
                    Text(errorMessage)
                              .font(.footnote)
                              .foregroundStyle(.red)
                              .frame(
                                  maxWidth: .infinity,
                                  alignment: .leading)
                              .padding(.top, 12)
                }
                loginButton
                auxiliaryActions
            }
            .padding(.horizontal ,24)
            .padding(.top , 40)
        }
        .task {
            focusedField = .email
        }
        .contentShape(Rectangle())
        .onTapGesture {
            focusedField = nil
        }
        .scrollDismissesKeyboard(.interactively)
    }
}


private extension LoginView
{
    var header : some View
    {
        VStack(spacing : 12){
            
            Image(systemName: "brain.head.profile" )
                .font(.system(size: 42))
                .frame(width: 76 , height: 76)
                .background(Color.accentColor.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 20))
            
            Text("Welcome Back")
                .font(.system(size: 32 , weight: .bold))
            
            Text("Sign in to continue learning")
                .font(.headline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom , 40)
    }
}

private extension LoginView
{
    var form : some View
    {
        VStack(spacing: 20){
            
            VStack(alignment: .leading, spacing: 8){
                
                Text("Email")
                    .font(.subheadline.weight(.medium))
                
                TextField("email@example.com",text: $viewModel.email)
                    .textFieldStyle(.roundedBorder)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .autocorrectionDisabled()
                    .disabled(viewModel.isLoading)
                    .focused($focusedField , equals: .email)
                    .submitLabel(.next)
                    .onSubmit {
                        focusedField = .password
                    }
            }
            
            VStack(alignment: .leading, spacing: 8){
                
                Text("Password")
                    .font(.subheadline.weight(.medium))
                
                SecureField("Enter your password" , text : $viewModel.password)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.password)
                    .disabled(viewModel.isLoading)
                    .focused($focusedField , equals: .password)
                    .submitLabel(.done)
                    .onSubmit {
                        focusedField = nil
                    }
            }
        }
    }
}

private extension LoginView {

    var loginButton: some View {
        Button {
            Task {
                await viewModel.login()
            }
        } label: {

            ZStack {

                Text("Login")
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
        .disabled(viewModel.isLoading)
        .padding(.top, 28)
    }
}


private extension LoginView
{
    var auxiliaryActions : some View
    {
        VStack(spacing : 20)
        {
            NavigationLink
            {
               ForgotPasswordView()
            }label: {
                Text("Forgot password?")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.blue)
            }
            .padding(.top, 16)
            .disabled(viewModel.isLoading)
            
             HStack(spacing: 4){
                 
                Text("Don't have an account?")
                    .foregroundStyle(.secondary)
                
                 NavigationLink{
                     RegisterView(appState: appState)
                 }label: {
                     Text("Register")
                         .font(.subheadline.weight(.medium))
                 }
                 .disabled(viewModel.isLoading)
            }
             .font(.subheadline)
             .padding(.top ,12)
        }
    }
}

#Preview {
    NavigationStack
    {
        LoginView(appState: AppState())
    }
}

