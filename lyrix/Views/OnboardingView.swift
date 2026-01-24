//
//  OnboardingView.swift
//  lyrix
//
//  Created by Pranav Bhatkar on 30/12/25.
//

import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
    @State private var currentStep = 0
    
    var body: some View {
        VStack {
            if currentStep == 0 {
                welcomeStep
                    .transition(.opacity)
            } else if currentStep == 1 {
                permissionStep
                    .transition(.opacity)
            } else {
                finalStep
                    .transition(.opacity)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .animation(.easeInOut(duration: 0.4), value: currentStep)
    }
    
    private var welcomeStep: some View {
        VStack(spacing: 32) {
            Image(systemName: "music.note.list")
                .font(.system(size: 80))
                .foregroundColor(.accentColor)
            
            VStack(spacing: 12) {
                Text("Welcome to Lyrix")
                    .font(.system(size: 36, weight: .bold))
                
                Text("Beautiful synchronized lyrics for your favorite music apps.")
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer().frame(height: 20)
            
            Button(action: { 
                withAnimation { currentStep += 1 }
            }) {
                Text("Get Started")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 48)
                    .padding(.vertical, 14)
                    .background(Color.accentColor)
                    .cornerRadius(12)
            }
            .buttonStyle(.plain)
        }
    }
    
    private var permissionStep: some View {
        VStack(spacing: 40) {
            VStack(spacing: 12) {
                Text("Music Permissions")
                    .font(.system(size: 32, weight: .bold))
                
                Text("Lyrix needs access to fetch song info from Music and Spotify.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            VStack(alignment: .leading, spacing: 24) {
                PermissionRow(
                    icon: "app.badge.checkmark",
                    title: "Automation Access",
                    description: "Allows Lyrix to talk to your music players."
                )
                
                PermissionRow(
                    icon: "lock.shield",
                    title: "Privacy First",
                    description: "No personal data is ever collected or shared."
                )
            }
            
            Spacer().frame(height: 10)
            
            HStack(spacing: 24) {
                Button(action: { 
                    withAnimation { currentStep -= 1 }
                }) {
                    Text("Back")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
                
                Button(action: {
                    triggerPermissionPrompt()
                    withAnimation { currentStep += 1 }
                }) {
                    Text("Grant Access")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 12)
                        .background(Color.accentColor)
                        .cornerRadius(12)
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    private var finalStep: some View {
        VStack(spacing: 32) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)
            
            VStack(spacing: 12) {
                Text("You're all set!")
                    .font(.system(size: 36, weight: .bold))
                
                Text("Open the floating window to see your lyrics in action.")
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer().frame(height: 20)
            
            Button(action: {
                hasCompletedOnboarding = true
            }) {
                Text("Start Using Lyrix")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 48)
                    .padding(.vertical, 14)
                    .background(Color.accentColor)
                    .cornerRadius(12)
            }
            .buttonStyle(.plain)
        }
    }
    
    private func triggerPermissionPrompt() {
        let script = "tell application \"Music\" to get name of current track"
        let spotifyScript = "tell application \"Spotify\" to get name of current track"
        
        DispatchQueue.global(qos: .userInitiated).async {
            var error: NSDictionary?
            if let scriptObject = NSAppleScript(source: script) {
                scriptObject.executeAndReturnError(&error)
            }
            if let scriptObject = NSAppleScript(source: spotifyScript) {
                scriptObject.executeAndReturnError(&error)
            }
        }
    }
}

struct PermissionRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.accentColor)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    OnboardingView()
}
