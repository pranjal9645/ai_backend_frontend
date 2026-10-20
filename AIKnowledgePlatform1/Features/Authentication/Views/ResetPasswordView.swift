//
//  ResetPasswordView.swift
//  AIKnowledgePlatform11
//
//  Created by Pranjal Singh on 08/10/26.
//

import SwiftUI

struct ResetPasswordView : View {

    @StateObject private var viewModel : ResetPasswordViewModel
    
    @FocusState private var focusedField : Field?
    
    @Environment(\.dismiss) private var dismiss
    
    private enum Field
    {
        case password
        case confirmPassword
    }
    
    init(token : String)
    {
        _viewModel = StateObject(wrappedValue: ResetPasswordViewModel(token: token))
    }
    
    var body: some View {
        
       
        Group
        {
            if viewModel.didResetPassword
            {
                successView
            }else
            {
                resetForm
            }
        }
        .navigationTitle(viewModel.didResetPassword ? "Password Reset" :"Reset Password")
        .navigationBarTitleDisplayMode(.inline)
    }
}


private extension ResetPasswordView
{
    var header : some View
    {
        VStack(spacing : 16){
            
            Image(systemName: "lock.rotation")
                .font(.system(size : 42))
                .foregroundStyle(.tint)
            
            VStack(spacing : 8){
                
                Text("Create a New Password")
                    .font(.title2.weight(.bold))
                
                Text("Choose a new password for your account.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom , 32)
    }
}

private extension ResetPasswordView
{
    var form : some View
    {
        VStack(spacing: 16) {
            
            SecureField(
                "New Password",
                text: $viewModel.password
            )
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .textContentType(.newPassword)
            .focused(
                $focusedField,
                equals: .password
            )
            .submitLabel(.next)
            .onSubmit {
                focusedField = .confirmPassword
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            
            SecureField("Confirm Password" , text: $viewModel.confirmPassword)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
                .textContentType(.oneTimeCode)
                .focused($focusedField , equals: .confirmPassword)
                .submitLabel(.done)
                .onSubmit {
                    focusedField = nil
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 14))
            
        }
    }
}

private extension ResetPasswordView
{
    var resetButton : some View
    {  VStack(spacing: 20){
        Button
        {
            focusedField = nil
            
            Task
            {
                await viewModel.resetPassword()
            }
            
        }label: {
            
            Group
            {
                if viewModel.isLoading
                {
                    ProgressView()
                        .tint(.white)
                }else
                {
                    Text("Reset Password")
                        .font(.headline)
                }
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(Color.accentColor)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .disabled(viewModel.isLoading || viewModel.cooldown.isActive)
        .padding(.top , 25)
        
        if viewModel.cooldown.isActive
        {
            Text("Please try again in \(viewModel.cooldown.remainingSeconds) seconds.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
        
    }
}

private extension ResetPasswordView
{
    var resetForm : some View
    {
        ScrollView
        {
            VStack(spacing : 0){
                
                header
                
                form
                
                if let errorMessage = viewModel.errorMessage
                {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .frame(maxWidth: .infinity , alignment: .leading)
                        .padding(.top , 12)
                }
                    
                resetButton
            }
            .padding(.horizontal , 24)
            .padding(.top , 40)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            focusedField = nil
        }
        .scrollDismissesKeyboard(.interactively)
    }
}

private extension ResetPasswordView
{
    var successView : some View
    {
        VStack(spacing : 0)
        {
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(.green)
                .padding(.bottom , 24)
            
            Text("Password Reset Successfully")
                .font(.title2.weight(.bold))
                .multilineTextAlignment(.center)
            
            Text(  "Your password has been updated successfully. You can now sign in with your new password.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.top , 12)
            
            Button
            {
                dismiss()
            }label: {
                
                Text("Back to Login")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color.accentColor)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.top , 32)
            
            Spacer()
        }
        .padding(.horizontal , 24)
    }
}

#Preview {
    ResetPasswordView(token: "iejj")
}
