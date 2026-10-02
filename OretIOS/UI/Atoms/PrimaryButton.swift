//
//  PrimaryButton.swift
//  OretIOS
//
//  Primary & Secondary Action Button Atoms (Aged Manuscript theme)
//

import SwiftUI

public enum ButtonVariant {
    case primary
    case secondary
}

public struct PrimaryButton: View {
    public let title: String
    public var icon: String? = nil
    public var isTrailingIcon: Bool = true
    public var variant: ButtonVariant = .primary
    public var isEnabled: Bool = true
    public let action: () -> Void

    public init(
        title: String,
        icon: String? = nil,
        isTrailingIcon: Bool = true,
        variant: ButtonVariant = .primary,
        isEnabled: Bool = true,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.isTrailingIcon = isTrailingIcon
        self.variant = variant
        self.isEnabled = isEnabled
        self.action = action
    }

    public var body: some View {
        Button(action: {
            if isEnabled {
                action()
            }
        }) {
            HStack(spacing: 8) {
                if let icon = icon, !isTrailingIcon {
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .semibold))
                }

                Text(title)
                    .font(AgedManuscriptTheme.Fonts.sansBody(size: 15, weight: .medium))

                if let icon = icon, isTrailingIcon {
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .semibold))
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .foregroundColor(foregroundColor)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(borderColor, lineWidth: variant == .secondary ? 1 : 0)
            )
            .shadow(color: variant == .primary ? Color.black.opacity(0.08) : Color.clear, radius: 2, y: 1)
            .opacity(isEnabled ? 1.0 : 0.5)
        }
        .disabled(!isEnabled)
        .buttonStyle(PressableButtonStyle())
    }

    private var foregroundColor: Color {
        switch variant {
        case .primary:
            return .white
        case .secondary:
            return AgedManuscriptTheme.Colors.inkPrimary
        }
    }

    private var backgroundColor: Color {
        switch variant {
        case .primary:
            return AgedManuscriptTheme.Colors.inkDark
        case .secondary:
            return Color.clear
        }
    }

    private var borderColor: Color {
        switch variant {
        case .primary:
            return Color.clear
        case .secondary:
            return AgedManuscriptTheme.Colors.parchmentBorder
        }
    }
}

// MARK: - Pressable Button Style
private struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.985 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.12), value: configuration.isPressed)
    }
}

#Preview {
    VStack(spacing: 16) {
        PrimaryButton(title: "Next", action: {})
        PrimaryButton(
            title: "Confirm & Initialize Workspace",
            icon: "arrow.right",
            isTrailingIcon: true,
            action: {}
        )
        PrimaryButton(
            title: "Back",
            variant: .secondary,
            action: {}
        )
    }
    .padding()
    .agedManuscriptBackground()
}
