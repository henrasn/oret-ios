//
//  TagBadge.swift
//  OretIOS
//
//  Tag Badge Atom for Aged Manuscript Mobile File Explorer
//

import SwiftUI

public struct TagBadge: View {
    public let tag: String
    public var count: Int? = nil
    public var isSelected: Bool = false
    public let action: () -> Void

    public init(
        tag: String,
        count: Int? = nil,
        isSelected: Bool = false,
        action: @escaping () -> Void
    ) {
        self.tag = tag
        self.count = count
        self.isSelected = isSelected
        self.action = action
    }

    public var displayText: String {
        if let count = count {
            return "\(tag) (\(count))"
        } else {
            return tag
        }
    }

    public var body: some View {
        Button(action: action) {
            Text(displayText)
                .font(
                    AgedManuscriptTheme.Fonts.sansLabel(
                        size: 12,
                        weight: isSelected ? .medium : .regular
                    )
                )
                .foregroundColor(isSelected ? .white : AgedManuscriptTheme.Colors.inkSecondary)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(
                    isSelected
                        ? AgedManuscriptTheme.Colors.inkDark
                        : AgedManuscriptTheme.Colors.parchmentField
                )
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(
                            isSelected ? Color.clear : AgedManuscriptTheme.Colors.parchmentBorder,
                            lineWidth: 1
                        )
                )
        }
        .buttonStyle(TagBadgeButtonStyle())
    }
}

private struct TagBadgeButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.12), value: configuration.isPressed)
    }
}

#Preview("Tag Badges") {
    HStack(spacing: 8) {
        TagBadge(tag: "#all", count: 34, isSelected: true, action: {})
        TagBadge(tag: "#project", count: 12, isSelected: false, action: {})
        TagBadge(tag: "#meeting", count: 8, isSelected: false, action: {})
        TagBadge(tag: "#ideas", count: 5, isSelected: false, action: {})
    }
    .padding()
    .agedManuscriptBackground()
}
