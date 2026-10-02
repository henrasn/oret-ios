//
//  BottomSearchDock.swift
//  OretIOS
//
//  Bottom Search Dock Molecule for Tags, Search, and New File/Folder Actions
//

import SwiftUI

public struct BottomSearchDock: View {
    public let tags: [(tag: String, count: Int)]
    public let selectedTag: String
    @Binding public var searchQuery: String
    public var isSyncing: Bool = false
    public let onSelectTag: (String) -> Void
    public let onNewFile: () -> Void
    public let onNewFolder: () -> Void

    public init(
        tags: [(tag: String, count: Int)],
        selectedTag: String,
        searchQuery: Binding<String>,
        isSyncing: Bool = false,
        onSelectTag: @escaping (String) -> Void,
        onNewFile: @escaping () -> Void,
        onNewFolder: @escaping () -> Void
    ) {
        self.tags = tags
        self.selectedTag = selectedTag
        self._searchQuery = searchQuery
        self.isSyncing = isSyncing
        self.onSelectTag = onSelectTag
        self.onNewFile = onNewFile
        self.onNewFolder = onNewFolder
    }

    public var body: some View {
        VStack(spacing: 10) {
            // Row 1: Tags horizontal strip
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(tags, id: \.tag) { item in
                        TagBadge(
                            tag: item.tag,
                            count: item.count,
                            isSelected: selectedTag == item.tag,
                            action: {
                                onSelectTag(item.tag)
                            }
                        )
                    }
                }
                .padding(.horizontal, 2)
            }

            // Row 2: Search input bar
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(AgedManuscriptTheme.Colors.inkMuted)

                TextField("Search files, words in file, or #tags...", text: $searchQuery)
                    .font(AgedManuscriptTheme.Fonts.sansBody(size: 13))
                    .foregroundColor(AgedManuscriptTheme.Colors.inkPrimary)
                    .autocorrectionDisabled(true)
                    .textInputAutocapitalization(.never)

                if !searchQuery.isEmpty {
                    Button(action: {
                        searchQuery = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 14))
                            .foregroundColor(AgedManuscriptTheme.Colors.inkMuted)
                    }
                }
            }
            .padding(.horizontal, 12)
            .frame(height: 40)
            .background(AgedManuscriptTheme.Colors.parchment)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(AgedManuscriptTheme.Colors.parchmentBorder, lineWidth: 1)
            )

            // Row 3: Action buttons row (+ New File, + New Folder)
            HStack(spacing: 8) {
                // Primary: New File (Disabled during active sync)
                Button(action: {
                    if !isSyncing {
                        onNewFile()
                    }
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: isSyncing ? "lock" : "plus")
                            .font(.system(size: 13, weight: isSyncing ? .regular : .bold))
                        Text(isSyncing ? "Locked" : "New File")
                            .font(AgedManuscriptTheme.Fonts.sansBody(size: 13, weight: .semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
                    .foregroundColor(isSyncing ? AgedManuscriptTheme.Colors.inkSecondary : .white)
                    .background(isSyncing ? AgedManuscriptTheme.Colors.parchmentBorder.opacity(0.8) : AgedManuscriptTheme.Colors.inkDark)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .shadow(color: Color.black.opacity(isSyncing ? 0 : 0.08), radius: 2, y: 1)
                }
                .disabled(isSyncing)
                .buttonStyle(PressableDockButtonStyle())
                .accessibilityLabel(Text(isSyncing ? "File creation locked during sync" : "Create New File"))

                // Secondary: New Folder (Disabled during active sync)
                Button(action: {
                    if !isSyncing {
                        onNewFolder()
                    }
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: isSyncing ? "lock" : "folder.badge.plus")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(AgedManuscriptTheme.Colors.inkMuted)
                        Text(isSyncing ? "Locked" : "New Folder")
                            .font(AgedManuscriptTheme.Fonts.sansBody(size: 13, weight: .medium))
                            .foregroundColor(isSyncing ? AgedManuscriptTheme.Colors.inkMuted : AgedManuscriptTheme.Colors.inkPrimary)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
                    .background(AgedManuscriptTheme.Colors.parchment)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(AgedManuscriptTheme.Colors.parchmentBorder, lineWidth: 1)
                    )
                    .opacity(isSyncing ? 0.45 : 1.0)
                }
                .disabled(isSyncing)
                .buttonStyle(PressableDockButtonStyle())
                .accessibilityLabel(Text(isSyncing ? "Folder creation locked during sync" : "Create New Folder"))
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 10)
        .padding(.bottom, 12)
        .background(AgedManuscriptTheme.Colors.parchmentField)
        .overlay(
            Rectangle()
                .fill(AgedManuscriptTheme.Colors.parchmentBorder)
                .frame(height: 1),
            alignment: .top
        )
    }
}

private struct PressableDockButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

#Preview("Bottom Search Dock") {
    BottomSearchDock(
        tags: [
            ("#all", 34),
            ("#project", 12),
            ("#meeting", 8),
            ("#ideas", 5),
            ("#todo", 4)
        ],
        selectedTag: "#all",
        searchQuery: .constant(""),
        onSelectTag: { _ in },
        onNewFile: {},
        onNewFolder: {}
    )
}
