//
//  ActionSheetRow.swift
//  OretIOS
//
//  Action Sheet Row Atom for File Options Bottom Sheet & Context Menus
//

import SwiftUI

public struct ActionSheetRow: View {
    public let icon: String
    public let title: String
    public var isDestructive: Bool = false
    public let action: () -> Void

    public init(
        icon: String,
        title: String,
        isDestructive: Bool = false,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.title = title
        self.isDestructive = isDestructive
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 17, weight: .regular))
                    .foregroundColor(
                        isDestructive
                            ? AgedManuscriptTheme.Colors.errorRed
                            : AgedManuscriptTheme.Colors.inkSecondary
                    )
                    .frame(width: 24, height: 24, alignment: .center)

                Text(title)
                    .font(
                        AgedManuscriptTheme.Fonts.sansBody(
                            size: 15,
                            weight: isDestructive ? .medium : .regular
                        )
                    )
                    .foregroundColor(
                        isDestructive
                            ? AgedManuscriptTheme.Colors.errorRed
                            : AgedManuscriptTheme.Colors.inkPrimary
                    )

                Spacer()
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 11)
            .contentShape(Rectangle())
        }
        .buttonStyle(ActionSheetRowButtonStyle(isDestructive: isDestructive))
    }
}

private struct ActionSheetRowButtonStyle: ButtonStyle {
    let isDestructive: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                configuration.isPressed
                    ? (isDestructive
                        ? AgedManuscriptTheme.Colors.errorContainer.opacity(0.5)
                        : AgedManuscriptTheme.Colors.parchmentField)
                    : Color.clear
            )
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

#Preview("Action Sheet Rows") {
    VStack(spacing: 4) {
        ActionSheetRow(icon: "pencil", title: "Rename Note", action: {})
        ActionSheetRow(icon: "doc.on.doc", title: "Duplicate Note", action: {})
        ActionSheetRow(icon: "folder", title: "Move to Another Folder", action: {})
        Divider()
        ActionSheetRow(icon: "trash", title: "Delete Note", isDestructive: true, action: {})
    }
    .padding()
    .background(AgedManuscriptTheme.Colors.parchment)
    .cornerRadius(12)
    .overlay(
        RoundedRectangle(cornerRadius: 12)
            .stroke(AgedManuscriptTheme.Colors.parchmentBorder, lineWidth: 1)
    )
    .padding()
    .agedManuscriptBackground()
}
