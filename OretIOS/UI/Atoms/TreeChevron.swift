//
//  TreeChevron.swift
//  OretIOS
//
//  Tree Chevron Atom for Hierarchical Folder Expansion
//

import SwiftUI

public struct TreeChevron: View {
    public let isExpanded: Bool
    public var action: (() -> Void)? = nil

    public init(
        isExpanded: Bool,
        action: (() -> Void)? = nil
    ) {
        self.isExpanded = isExpanded
        self.action = action
    }

    public var body: some View {
        Button(action: {
            action?()
        }) {
            Image(systemName: "chevron.right")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(AgedManuscriptTheme.Colors.inkMuted)
                .rotationEffect(.degrees(isExpanded ? 90 : 0))
                .animation(.easeInOut(duration: 0.18), value: isExpanded)
                .frame(width: 20, height: 20)
                .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(action == nil)
    }
}

#Preview("Tree Chevrons") {
    VStack(spacing: 16) {
        HStack(spacing: 12) {
            TreeChevron(isExpanded: false)
            Text("Collapsed Folder")
                .font(AgedManuscriptTheme.Fonts.sansBody(size: 14))
                .foregroundColor(AgedManuscriptTheme.Colors.inkPrimary)
        }
        HStack(spacing: 12) {
            TreeChevron(isExpanded: true)
            Text("Expanded Folder")
                .font(AgedManuscriptTheme.Fonts.sansBody(size: 14))
                .foregroundColor(AgedManuscriptTheme.Colors.inkPrimary)
        }
    }
    .padding()
    .agedManuscriptBackground()
}
