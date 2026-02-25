//
//  SettingsTabs.swift
//  lyrix
//
//  Created by Pranav Bhatkar on 30/12/25.
//

import Foundation

enum SettingsTabs: Identifiable, CaseIterable, Hashable {

    case home
    case library
    case customize
    case about

    var id: String {
        switch self {
        case .home:
            "home"
        case .library:
            "library"
        case .customize:
            "customize"
        case .about:
            "about"
        }
    }

    var displayName: String {
        switch self {
        case .home:
            "Home"
        case .library:
            "Library"
        case .customize:
            "Customize"
        case .about:
            "About"
        }
    }

    var imageName: String {
        switch self {
        case .home:
            "house.fill"
        case .library:
            "music.note.list"
        case .customize:
            "paintbrush"
        case .about:
            "info.circle"
        }
    }

    static var allCases: [SettingsTabs] {
        [.home, .library, .customize, .about]
    }

    static func === (lhs: SettingsTabs, rhs: SettingsTabs) -> Bool {
         lhs.id == rhs.id
    }
}
