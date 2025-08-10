import SwiftUI

enum EditorTheme: String, CaseIterable, Identifiable, Codable {
    case light
    case dark
    case solarized

    var id: String { rawValue }

    var name: String {
        switch self {
        case .light: return "Light"
        case .dark: return "Dark"
        case .solarized: return "Solarized"
        }
    }

    var background: Color {
        switch self {
        case .light: return Color(NSColor.textBackgroundColor)
        case .dark: return Color.black
        case .solarized: return Color(red: 0.00, green: 0.17, blue: 0.21)
        }
    }

    var text: Color {
        switch self {
        case .light: return Color(NSColor.textColor)
        case .dark: return Color.white
        case .solarized: return Color(red: 0.51, green: 0.58, blue: 0.59)
        }
    }

    var accent: Color {
        switch self {
        case .light: return .blue
        case .dark: return .mint
        case .solarized: return Color(red: 0.65, green: 0.74, blue: 0.18)
        }
    }

    var preferredColorScheme: ColorScheme {
        switch self {
        case .light: return .light
        case .dark, .solarized: return .dark
        }
    }
}


