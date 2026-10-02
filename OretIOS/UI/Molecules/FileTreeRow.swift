//
//  FileTreeRow.swift
//  OretIOS
//
//  Hierarchical File Tree Node Row Molecule (Aged Manuscript theme)
//

import SwiftUI

public struct FileTreeRow: View {
    public let item: FileItem
    public let depth: Int
    public var isSelected: Bool = false
    public let onToggleExpand: () -> Void
    public let onSelect: () -> Void
    public let onOptionsTapped: () -> Void

    public init(
        item: FileItem,
        depth: Int = 0,
        isSelected: Bool = false,
        onToggleExpand: @escaping () -> Void,
        onSelect: @escaping () -> Void,
        onOptionsTapped: @escaping () -> Void
    ) {
        self.item = item
        self.depth = depth
        self.isSelected = isSelected
        self.onToggleExpand = onToggleExpand
        self.onSelect = onSelect
        self.onOptionsTapped = onOptionsTapped
    }

    public var body: some View {
        HStack(spacing: 0) {
            // Indentation with visual border guide lines for nested levels
            if depth > 0 {
                HStack(spacing: 0) {
                    ForEach(0..<depth, id: \.self) { _ in
                        Rectangle()
                            .fill(AgedManuscriptTheme.Colors.parchmentBorder.opacity(0.7))
                            .frame(width: 1)
                            .padding(.leading, 12)
                            .padding(.trailing, 8)
                    }
                }
            }

            // Main row contents
            HStack(spacing: 8) {
                // Leading Chevron for folder or empty spacer for leaf file
                if item.isDirectory {
                    TreeChevron(isExpanded: item.isExpanded, action: onToggleExpand)
                } else {
                    Color.clear
                        .frame(width: 20, height: 20)
                }

                // File / Directory Icon
                Image(systemName: item.sfSymbolName)
                    .font(.system(size: item.isDirectory ? 18 : 17, weight: .regular))
                    .foregroundColor(
                        item.isDirectory
                            ? AgedManuscriptTheme.Colors.folderAmber
                            : AgedManuscriptTheme.Colors.inkMuted
                    )

                // Item Name
                Text(item.name)
                    .font(
                        AgedManuscriptTheme.Fonts.sansBody(
                            size: depth == 0 ? 15 : 14,
                            weight: item.isDirectory ? .medium : .regular
                        )
                    )
                    .foregroundColor(AgedManuscriptTheme.Colors.inkPrimary)
                    .lineLimit(1)
                    .truncationMode(.tail)

                Spacer()

                // Optional Tag / Extension Badge for files
                if !item.isDirectory && item.fileExtension == "md" {
                    Text("MD")
                        .font(AgedManuscriptTheme.Fonts.monoCode(size: 10, weight: .medium))
                        .foregroundColor(AgedManuscriptTheme.Colors.inkSecondary)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(AgedManuscriptTheme.Colors.parchmentField)
                        .cornerRadius(3)
                }

                // Trailing More Options Button (ellipsis)
                Button(action: onOptionsTapped) {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(AgedManuscriptTheme.Colors.inkMuted)
                        .frame(width: 28, height: 28)
                        .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())
                .accessibilityLabel(Text("Options for \(item.name)"))
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(
                isSelected
                    ? AgedManuscriptTheme.Colors.parchmentCard
                    : Color.clear
            )
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(
                        isSelected ? AgedManuscriptTheme.Colors.parchmentBorder : Color.clear,
                        lineWidth: 1
                    )
            )
            .contentShape(Rectangle())
            .onTapGesture {
                if item.isDirectory {
                    onToggleExpand()
                } else {
                    onSelect()
                }
            }
        }
    }
}

#Preview("File Tree Rows") {
    VStack(spacing: 2) {
        FileTreeRow(
            item: FileItem(name: "Work", path: "/Work", isDirectory: true, isExpanded: true),
            depth: 0,
            isSelected: false,
            onToggleExpand: {},
            onSelect: {},
            onOptionsTapped: {}
        )
        FileTreeRow(
            item: FileItem(name: "Q3 Planning", path: "/Work/Q3 Planning", isDirectory: true, isExpanded: true),
            depth: 1,
            isSelected: false,
            onToggleExpand: {},
            onSelect: {},
            onOptionsTapped: {}
        )
        FileTreeRow(
            item: FileItem(name: "roadmap.md", path: "/Work/Q3 Planning/roadmap.md", isDirectory: false),
            depth: 2,
            isSelected: true,
            onToggleExpand: {},
            onSelect: {},
            onOptionsTapped: {}
        )
        FileTreeRow(
            item: FileItem(name: "budget.md", path: "/Work/Q3 Planning/budget.md", isDirectory: false),
            depth: 2,
            isSelected: false,
            onToggleExpand: {},
            onSelect: {},
            onOptionsTapped: {}
        )
        FileTreeRow(
            item: FileItem(name: "Personal", path: "/Personal", isDirectory: true, isExpanded: false),
            depth: 0,
            isSelected: false,
            onToggleExpand: {},
            onSelect: {},
            onOptionsTapped: {}
        )
        FileTreeRow(
            item: FileItem(name: "quick-scratchpad.md", path: "/quick-scratchpad.md", isDirectory: false),
            depth: 0,
            isSelected: false,
            onToggleExpand: {},
            onSelect: {},
            onOptionsTapped: {}
        )
    }
    .padding()
    .agedManuscriptBackground()
}
