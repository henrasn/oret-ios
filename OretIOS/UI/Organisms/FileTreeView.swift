//
//  FileTreeView.swift
//  OretIOS
//
//  Hierarchical File Tree Organism supporting Inline Creation and Expansion
//

import SwiftUI

public struct FileTreeView: View {
    public let items: [FileItem]
    public var selectedItemId: String?
    public var inlineCreationTarget: String?
    @Binding public var inlineCreationName: String
    public var inlineCreationIsFolder: Bool
    public let onToggleExpand: (FileItem) -> Void
    public let onSelect: (FileItem) -> Void
    public let onOptions: (FileItem) -> Void
    public let onCommitInlineCreation: () -> Void
    public let onCancelInlineCreation: () -> Void

    public init(
        items: [FileItem],
        selectedItemId: String? = nil,
        inlineCreationTarget: String? = nil,
        inlineCreationName: Binding<String> = .constant(""),
        inlineCreationIsFolder: Bool = false,
        onToggleExpand: @escaping (FileItem) -> Void,
        onSelect: @escaping (FileItem) -> Void,
        onOptions: @escaping (FileItem) -> Void,
        onCommitInlineCreation: @escaping () -> Void = {},
        onCancelInlineCreation: @escaping () -> Void = {}
    ) {
        self.items = items
        self.selectedItemId = selectedItemId
        self.inlineCreationTarget = inlineCreationTarget
        self._inlineCreationName = inlineCreationName
        self.inlineCreationIsFolder = inlineCreationIsFolder
        self.onToggleExpand = onToggleExpand
        self.onSelect = onSelect
        self.onOptions = onOptions
        self.onCommitInlineCreation = onCommitInlineCreation
        self.onCancelInlineCreation = onCancelInlineCreation
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 2) {
                // Root-level inline creation if active at "/"
                if inlineCreationTarget == "/" {
                    inlineCreationRow(depth: 0)
                }

                // Recursive tree elements
                ForEach(items) { rootItem in
                    treeNodeView(item: rootItem, depth: 0)
                }

                // Blank area ornamental manuscript divider
                ornamentalManuscriptDivider
            }
            .padding(.horizontal, 14)
            .padding(.top, 10)
            .padding(.bottom, 24)
        }
    }

    // MARK: - Recursive Node View
    @ViewBuilder
    private func treeNodeView(item: FileItem, depth: Int) -> some View {
        FileTreeRow(
            item: item,
            depth: depth,
            isSelected: item.id == selectedItemId,
            onToggleExpand: {
                onToggleExpand(item)
            },
            onSelect: {
                onSelect(item)
            },
            onOptionsTapped: {
                onOptions(item)
            }
        )

        // If folder is expanded, render children and any inline creation row targeted at this folder
        if item.isDirectory && item.isExpanded {
            // Inline creation row inside this folder
            if inlineCreationTarget == item.path {
                inlineCreationRow(depth: depth + 1)
            }

            ForEach(item.children) { child in
                treeNodeView(item: child, depth: depth + 1)
            }
        }
    }

    // MARK: - Inline Creation Row (Stitch 8e5de384bf58404fac25724f7cfbae24)
    @ViewBuilder
    private func inlineCreationRow(depth: Int) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 0) {
                if depth > 0 {
                    ForEach(0..<depth, id: \.self) { _ in
                        Rectangle()
                            .fill(AgedManuscriptTheme.Colors.parchmentBorder.opacity(0.7))
                            .frame(width: 1)
                            .padding(.leading, 12)
                            .padding(.trailing, 8)
                    }
                }

                HStack(spacing: 8) {
                    Image(systemName: inlineCreationIsFolder ? "folder" : "doc.text")
                        .font(.system(size: 16))
                        .foregroundColor(AgedManuscriptTheme.Colors.inkSecondary)

                    TextField("new-item", text: $inlineCreationName)
                        .font(AgedManuscriptTheme.Fonts.sansBody(size: 14, weight: .medium))
                        .foregroundColor(AgedManuscriptTheme.Colors.inkPrimary)
                        .autocorrectionDisabled(true)
                        .textInputAutocapitalization(.never)
                        .onSubmit {
                            onCommitInlineCreation()
                        }

                    if !inlineCreationIsFolder {
                        Text(".md")
                            .font(AgedManuscriptTheme.Fonts.monoCode(size: 11, weight: .medium))
                            .foregroundColor(AgedManuscriptTheme.Colors.inkSecondary)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(AgedManuscriptTheme.Colors.parchmentCard)
                            .cornerRadius(3)
                    }

                    // Save Checkmark Button
                    Button(action: onCommitInlineCreation) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(AgedManuscriptTheme.Colors.inkDark)
                            .padding(5)
                            .background(AgedManuscriptTheme.Colors.parchmentCard)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal, 10)
                .frame(height: 38)
                .background(AgedManuscriptTheme.Colors.parchmentField)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(AgedManuscriptTheme.Colors.inkDark, lineWidth: 1.5)
                )
            }

            // Inline helper caption
            Text("Tap ✓ or return to create • Tap outside to cancel")
                .font(AgedManuscriptTheme.Fonts.sansLabel(size: 11))
                .foregroundColor(AgedManuscriptTheme.Colors.inkSecondary)
                .padding(.leading, CGFloat(depth) * 20 + 8)
        }
        .padding(.vertical, 3)
    }

    // MARK: - Ornamental Manuscript Divider
    private var ornamentalManuscriptDivider: some View {
        HStack(spacing: 12) {
            Rectangle()
                .fill(AgedManuscriptTheme.Colors.parchmentBorder)
                .frame(height: 1)
                .frame(maxWidth: 48)

            Image(systemName: "square.and.pencil")
                .font(.system(size: 14))
                .foregroundColor(AgedManuscriptTheme.Colors.inkMuted.opacity(0.45))

            Rectangle()
                .fill(AgedManuscriptTheme.Colors.parchmentBorder)
                .frame(height: 1)
                .frame(maxWidth: 48)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 28)
        .padding(.bottom, 12)
    }
}

#Preview("File Tree View") {
    FileTreeView(
        items: FileItem.sampleHierarchy,
        selectedItemId: "note_roadmap",
        inlineCreationTarget: "/Work/Q3 Planning",
        inlineCreationName: .constant("sprint-retrospective"),
        inlineCreationIsFolder: false,
        onToggleExpand: { _ in },
        onSelect: { _ in },
        onOptions: { _ in }
    )
    .agedManuscriptBackground()
}
