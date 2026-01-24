//
//  lyrixApp.swift
//  lyrix
//
//  Created by Pranav Bhatkar on 30/12/25.
//

import SwiftUI

@main
struct lyrixApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(width: 850, height: 600)
        }
        .windowResizability(.contentSize)
        .windowStyle(.hiddenTitleBar)
    }
}
