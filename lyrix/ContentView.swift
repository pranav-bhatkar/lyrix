//
//  ContentView.swift
//  lyrix
//
//  Created by Pranav Bhatkar on 30/12/25.
//

import SwiftUI

struct ContentView: View {
    @State private var selection = SettingsTabs.home
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
    
    var body: some View {
        Group {
            if !hasCompletedOnboarding {
                OnboardingView()
            } else {
                NavigationSplitView {
                    SideBarView(selection: $selection)
                        .navigationSplitViewColumnWidth(min: 180, ideal: 200)
                } detail: {
                    switch selection {
                    case .home:
                        SettingsView()
                    case .customize:
                        CustomizationView()
                    case .about:
                        AboutView()
                    }
                }
                .navigationTitle("")
            }
        }
        .transition(.opacity)
        .animation(.easeInOut(duration: 0.4), value: hasCompletedOnboarding)
    }
}

#Preview {
    ContentView()
        .frame(width: 750, height: 650)
}

