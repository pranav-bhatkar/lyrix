//
//  SideBarView.swift
//  lyrix
//
//  Created by Pranav Bhatkar on 30/12/25.
//

import SwiftUI

struct SideBarView: View {
    @Binding var selection: SettingsTabs
    
    var body: some View {
        List(selection: $selection) {
            ForEach(SettingsTabs.allCases, id: \.self) { option in
                Label(option.displayName, systemImage: option.imageName)
                    .tag(option)
            }
        }
    }
}

#Preview {
    SideBarView(
        selection: .constant(.home)
    )
        .listStyle(.sidebar)
}
