//
//  AgedManuscriptTheme.swift
//  OretIOS
//
//  Design Tokens & Typography for Aged Manuscript Theme
//

import SwiftUI

public enum AgedManuscriptTheme {
    // MARK: - Color Palette Tokens
    public enum Colors {
        /// Base parchment background: #FFF9EB
        public static let parchment = Color(hex: "#FFF9EB")
        /// Elevated parchment card surface: #FAF4E6
        public static let parchmentCard = Color(hex: "#FAF4E6")
        /// Input field & container background: #F4EEDB
        public static let parchmentField = Color(hex: "#F4EEDB")
        /// Subtle paper demarcations & borders: #E6D9BC
        public static let parchmentBorder = Color(hex: "#E6D9BC")
        /// Alternative dim border: #E5DAC2
        public static let dimBorder = Color(hex: "#E5DAC2")
        /// Deep ink for primary headers & titles: #1E1C10
        public static let inkPrimary = Color(hex: "#1E1C10")
        /// High-contrast ink for actions & active indicators: #171818
        public static let inkDark = Color(hex: "#171818")
        /// Sepia / faded ink for secondary copy: #635E4F
        public static let inkSecondary = Color(hex: "#635E4F")
        public static let sepia = Color(hex: "#635E4F")
        /// Muted ink for icons & subtle labels: #8C7E68
        public static let inkMuted = Color(hex: "#8C7E68")
        /// Terracotta / wax seal crimson accent: #8C362B
        public static let crimsonAccent = Color(hex: "#8C362B")
        /// Olive sage for security & verified statuses: #4A6350
        public static let oliveSage = Color(hex: "#4A6350")
        /// Warm pedestal shadow: #EDE3CF
        public static let warmShadow = Color(hex: "#EDE3CF")
        /// Stitch folder amber accent: #A67C37
        public static let folderAmber = Color(hex: "#A67C37")
        /// Synced status green: #2E7D32
        public static let statusGreen = Color(hex: "#2E7D32")
        /// Stitch delete / error warning red: #BA1A1A
        public static let errorRed = Color(hex: "#BA1A1A")
        /// Stitch delete warning container background: #FFDAD6
        public static let errorContainer = Color(hex: "#FFDAD6")
    }

    // MARK: - Typography Modifiers
    public enum Fonts {
        /// Serif headline styled after Source Serif 4
        public static func serifTitle(size: CGFloat = 24, weight: Font.Weight = .semibold) -> Font {
            // Falls back safely to System Serif if custom font file is not embedded in bundle
            return Font.system(size: size, weight: weight, design: .serif)
        }

        /// Sans body copy styled after Inter
        public static func sansBody(size: CGFloat = 15, weight: Font.Weight = .regular) -> Font {
            return Font.system(size: size, weight: weight, design: .default)
        }

        /// Sans caption / label styled after Inter
        public static func sansLabel(size: CGFloat = 12, weight: Font.Weight = .medium) -> Font {
            return Font.system(size: size, weight: weight, design: .default)
        }

        /// Monospace code font for directory paths & technical identifiers
        public static func monoCode(size: CGFloat = 14, weight: Font.Weight = .medium) -> Font {
            return Font.system(size: size, weight: weight, design: .monospaced)
        }
    }
}

// MARK: - Color Hex Initializer
public extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - View Background Modifier
public struct ParchmentBackgroundModifier: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .background(AgedManuscriptTheme.Colors.parchment.ignoresSafeArea())
    }
}

public extension View {
    func agedManuscriptBackground() -> some View {
        self.modifier(ParchmentBackgroundModifier())
    }
}
