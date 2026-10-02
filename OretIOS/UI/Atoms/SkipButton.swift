//
//  SkipButton.swift
//  OretIOS
//
//  Skip Button Atom for Onboarding Navigation
//

import SwiftUI

public struct SkipButton: View {
    public let title: String
    public let action: () -> Void

    public init(title: String = "Skip", action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Text(title)
                .font(AgedManuscriptTheme.Fonts.sansBody(size: 15, weight: .medium))
                .foregroundColor(AgedManuscriptTheme.Colors.inkSecondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
        }
        .buttonStyle(SkipButtonStyle())
        .accessibilityLabel(Text("Skip onboarding"))
    }
}

private struct SkipButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.6 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

#Preview {
    HStack {
        Spacer()
        SkipButton(action: {})
    }
    .padding()
    .agedManuscriptBackground()
}
