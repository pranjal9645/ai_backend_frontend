//
//  ForgotPasswordView.swift
//  AIKnowledgePlatform11
//
//  Created by Pranjal Singh on 07/10/26.
//

import Foundation
import SwiftUI

struct ForgotPasswordView : View
{
    
    @StateObject private var viewModel = ForgotPasswordViewModel()
    @Environment(\.dismiss) private var dismiss
    
    @FocusState private var isEmailFocused: Bool
    
    var body: some View
    {
        ScrollView
        {
            VStack(spacing: 0){
                header
                
                if viewModel.didSendRequest
                {
                   successContent
                }else
                {
                    formContent
                }
                
                Spacer(minLength: 40)
            }
            .padding(.horizontal,24)
            .padding(.top , 40)
        }
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle("Forgot Password")
        .navigationBarTitleDisplayMode(.inline)
    }
}


private extension ForgotPasswordView
{
    var header : some View
    {
        VStack(spacing : 12)
        {
            Image(systemName: "lock.rotation")
                .font(.system(size: 40))
                .frame(width: 76, height: 76)
                 .background(Color.accentColor.opacity(0.12))
                 .clipShape(RoundedRectangle(cornerRadius: 20))
            
            Text("Reset your password")
                    .font(.system(size: 30, weight: .bold))
                    .multilineTextAlignment(.center)
            
            Text("Enter your email address and we'll send you a link to reset your password.")
                     .font(.subheadline)
                     .foregroundStyle(.secondary)
                     .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom , 36)
    }
}

private extension ForgotPasswordView
{
    var formContent : some View
    {
        VStack(spacing: 20)
        {
            VStack(alignment: .leading , spacing: 8)
            {
                Text("Email")
                    .font(.subheadline.weight(.medium))
                
                TextField("email@example.com",text: $viewModel.email)
                                   .textFieldStyle(.roundedBorder)
                                   .textInputAutocapitalization(.never)
                                   .keyboardType(.emailAddress)
                                   .textContentType(.emailAddress)
                                   .autocorrectionDisabled(true)
                                   .focused($isEmailFocused)
                                   .submitLabel(.done)
                                   .onSubmit {
                                       Task
                                       {
                                           await viewModel.sendResetLink()
                                       }
                                   }
                                   .disabled(viewModel.isLoading)
            }
            
            if let errorMessage = viewModel.errorMessage
            {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity , alignment: .leading)
            }
            
            Button
            {
                Task
                {
                    await viewModel.sendResetLink()
                }
            }label: {
                
                ZStack
                {
                    Text("Send Reset Link")
                        .font(.headline)
                        .opacity(
                            viewModel.isLoading ? 0 : 1
                        )
                    if viewModel.isLoading
                    {
                        ProgressView()
                            .tint(.white)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 52)
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.isLoading || viewModel.cooldown.isActive)
            
            if viewModel.cooldown.isActive
            {
                Text("Please try again in \(viewModel.cooldown.remainingSeconds) seconds.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
            }
            
        }
    }
}

private extension ForgotPasswordView
{
    var successContent : some View
    {
        VStack(spacing: 24)
        {
            Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 54))
                    .foregroundStyle(.green)
            Text("Check Your Email")
                .font(.title2.weight(.bold))
            
            Text("If an account exists for this email address, we've sent a password reset link.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
            Button
            {
                dismiss()
            }label: {
               
                Text("Back to Login")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    
    NavigationStack
    {
        ForgotPasswordView()
    }
}
