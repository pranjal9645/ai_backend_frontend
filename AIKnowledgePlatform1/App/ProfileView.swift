//
//  ProfileView.swift
//  AIKnowledgePlatform11
//
//  Created by Pranjal Singh on 20/10/26.
//


import SwiftUI

struct ProfileView: View {
   private let appState: AppState

    @State private var showLogoutConfirmation = false
    @State private var isLoggingOut = false
    @State private var logoutError: String?

    @State private var user: UserResponse?
    
    init(appState : AppState){
        
        self.appState = appState
        user = nil
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(spacing: 12) {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 72))
                            .foregroundStyle(.indigo)

                        Text(user?.name ?? "name")
                            .font(.title2.weight(.semibold))

                        Text(user?.email ?? "email")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .listRowBackground(Color.clear)
                }

                Section("Account Information") {
                    LabeledContent("Name", value: user?.name ?? "Name")
                    LabeledContent("Email", value: user?.email ?? "email")
                }

                Section {
                    Button(role: .destructive) {
                        showLogoutConfirmation = true
                    } label: {
                        HStack {
                            Spacer()

                            if isLoggingOut {
                                ProgressView()
                                    .padding(.trailing, 8)
                            }

                            Text(isLoggingOut ? "Logging Out..." : "Log Out")
                                .fontWeight(.semibold)

                            Spacer()
                        }
                    }
                    .disabled(isLoggingOut)
                }
            }
            .navigationTitle("Profile")
            .confirmationDialog(
                "Log out of MindVault?",
                isPresented: $showLogoutConfirmation,
                titleVisibility: .visible
            ) {
                Button("Log Out", role: .destructive) {
                    Task {
                        await logout()
                    }
                }

                Button("Cancel", role: .cancel) {}
            } message: {
                Text("You will need to log in again to access your account.")
            }
            .alert(
                "Couldn't Log Out",
                isPresented: Binding(
                    get: { logoutError != nil },
                    set: { if !$0 { logoutError = nil } }
                )
            ) {
                Button("OK", role: .cancel) {
                    logoutError = nil
                }
            } message: {
                Text(logoutError ?? "Please try again.")
            }
        }
        .task {
            do{
                user = try await AuthService.shared.fetchUser()
            }catch
            {
                print(error.localizedDescription)
            }
        }
    }

    @MainActor
    private func logout() async {
        isLoggingOut = true
        defer { isLoggingOut = false }

        do {
            
            try await AuthService.shared.logout()

        } catch {
            logoutError = error.localizedDescription
        }
        
        TokenStore.shared.deleteAllTokens()
        appState.phase = .unauthenticated
    }
}
