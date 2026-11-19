import SwiftUI
import UIKit

/// A small shared palette drawn from the parchment-scroll app icon.
/// Colors adapt to the system appearance; chapter completion stays green.
enum AppStyle {
    static let canvas = adaptive(light: 0xF7F3ED, dark: 0x191613)
    static let surface = adaptive(light: 0xFFFCF7, dark: 0x25201B)
    static let soft = adaptive(light: 0xF0E5D8, dark: 0x33291F)
    static let ink = adaptive(light: 0x382A20, dark: 0xF3E8D9)
    static let bronze = adaptive(light: 0x875632, dark: 0xD5AD83)
    static let selected = Color(red: 0.43, green: 0.28, blue: 0.18)
    static let border = bronze.opacity(0.12)
    static let shadow = Color(red: 0.30, green: 0.19, blue: 0.11).opacity(0.07)

    static var backdrop: LinearGradient {
        LinearGradient(colors: [canvas, canvas, soft.opacity(0.55)], startPoint: .top, endPoint: .bottomTrailing)
    }

    static var paper: LinearGradient {
        LinearGradient(colors: [surface, surface, soft.opacity(0.55)], startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    static var button: LinearGradient {
        LinearGradient(colors: [Color(red: 0.30, green: 0.20, blue: 0.14),
                                Color(red: 0.49, green: 0.31, blue: 0.19)],
                       startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    private static func adaptive(light: UInt32, dark: UInt32) -> Color {
        Color(uiColor: UIColor { traits in
            let hex = traits.userInterfaceStyle == .dark ? dark : light
            return UIColor(red: CGFloat((hex >> 16) & 255) / 255,
                           green: CGFloat((hex >> 8) & 255) / 255,
                           blue: CGFloat(hex & 255) / 255, alpha: 1)
        })
    }
}
