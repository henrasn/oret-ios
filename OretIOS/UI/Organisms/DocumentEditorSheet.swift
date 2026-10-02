//
//  DocumentEditorSheet.swift
//  OretIOS
//
//  Markdown Document Viewer and Editor Organism (Aged Manuscript theme)
//  Allows reading, editing, and saving Markdown documents in the local sandbox.
//

import SwiftUI

public struct DocumentEditorSheet: View {
    public let item: FileItem
    public let initialContent: String
    @Binding public var isPresented: Bool
    public let onSave: (String) -> Void

    @State private var content: String
    @State private var hasUnsavedChanges: Bool = false
    @State private var showSavedIndicator: Bool = false

    public init(
        item: FileItem,
        initialContent: String,
        isPresented: Binding<Bool>,
        onSave: @escaping (String) -> Void
    ) {
        self.item = item
        self.initialContent = initialContent
        self._isPresented = isPresented
        self.onSave = onSave
        self._content = State(initialValue: initialContent)
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                // Background
                AgedManuscriptTheme.Colors.parchment
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Document Metadata Subheader
                    documentMetadataBar

                    Divider()
                        .background(AgedManuscriptTheme.Colors.parchmentBorder)

                    // Markdown Text Editor Body
                    ZStack(alignment: .topLeading) {
                        TextEditor(text: $content)
                            .font(AgedManuscriptTheme.Fonts.sansBody(size: 15))
                            .foregroundColor(AgedManuscriptTheme.Colors.inkPrimary)
                            .scrollContentBackground(.hidden)
                            .background(AgedManuscriptTheme.Colors.parchment)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .onChange(of: content) { _, newValue in
                                hasUnsavedChanges = (newValue != initialContent)
                            }

                        if content.isEmpty {
                            Text("Start typing markdown note here...")
                                .font(AgedManuscriptTheme.Fonts.sansBody(size: 15))
                                .foregroundColor(AgedManuscriptTheme.Colors.inkSecondary.opacity(0.6))
                                .padding(.horizontal, 20)
                                .padding(.vertical, 20)
                                .allowsHitTesting(false)
                        }
                    }

                    // Bottom Statistics Footer
                    documentFooterBar
                }
            }
            .navigationTitle(item.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        isPresented = false
                    }
                    .font(AgedManuscriptTheme.Fonts.sansBody(size: 15, weight: .regular))
                    .foregroundColor(AgedManuscriptTheme.Colors.inkSecondary)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(action: saveDocument) {
                        HStack(spacing: 4) {
                            if showSavedIndicator {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 12, weight: .bold))
                                Text("Saved")
                            } else {
                                Image(systemName: "square.and.arrow.down")
                                    .font(.system(size: 12, weight: .semibold))
                                Text("Save")
                            }
                        }
                        .font(AgedManuscriptTheme.Fonts.sansBody(size: 14, weight: .medium))
                        .foregroundColor(hasUnsavedChanges ? .white : AgedManuscriptTheme.Colors.inkSecondary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            hasUnsavedChanges
                                ? AgedManuscriptTheme.Colors.inkDark
                                : AgedManuscriptTheme.Colors.parchmentField
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(AgedManuscriptTheme.Colors.parchmentBorder, lineWidth: 1)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }

    // MARK: - Metadata Bar
    private var documentMetadataBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "doc.text")
                .font(.system(size: 14))
                .foregroundColor(AgedManuscriptTheme.Colors.inkSecondary)

            Text(item.path)
                .font(AgedManuscriptTheme.Fonts.monoCode(size: 12, weight: .medium))
                .foregroundColor(AgedManuscriptTheme.Colors.inkSecondary)
                .lineLimit(1)

            Spacer()

            // Tag chips
            ForEach(item.tags.filter { $0 != "#all" }.prefix(3), id: \.self) { tag in
                TagBadge(tag: tag, count: nil, isSelected: false) {}
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(AgedManuscriptTheme.Colors.parchmentField)
    }

    // MARK: - Footer Bar
    private var documentFooterBar: some View {
        HStack(spacing: 12) {
            Text("\(wordCount) words")
                .font(AgedManuscriptTheme.Fonts.sansLabel(size: 11, weight: .regular))
                .foregroundColor(AgedManuscriptTheme.Colors.inkSecondary)

            Text("•")
                .foregroundColor(AgedManuscriptTheme.Colors.inkSecondary.opacity(0.4))

            Text("\(content.count) characters")
                .font(AgedManuscriptTheme.Fonts.sansLabel(size: 11, weight: .regular))
                .foregroundColor(AgedManuscriptTheme.Colors.inkSecondary)

            Spacer()

            if hasUnsavedChanges {
                Text("Unsaved changes")
                    .font(AgedManuscriptTheme.Fonts.sansLabel(size: 11, weight: .medium))
                    .foregroundColor(AgedManuscriptTheme.Colors.crimsonAccent)
            } else {
                Text("Saved to sandbox")
                    .font(AgedManuscriptTheme.Fonts.sansLabel(size: 11, weight: .regular))
                    .foregroundColor(AgedManuscriptTheme.Colors.oliveSage)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(AgedManuscriptTheme.Colors.parchmentField)
        .overlay(
            Rectangle()
                .fill(AgedManuscriptTheme.Colors.parchmentBorder)
                .frame(height: 1),
            alignment: .top
        )
    }

    private var wordCount: Int {
        let components = content.components(separatedBy: .whitespacesAndNewlines)
        return components.filter { !$0.isEmpty }.count
    }

    private func saveDocument() {
        onSave(content)
        hasUnsavedChanges = false
        withAnimation {
            showSavedIndicator = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation {
                showSavedIndicator = false
            }
        }
    }
}

// MARK: - SwiftUI #Preview

#Preview("Document Editor Sheet") {
    DocumentEditorSheet(
        item: FileItem(
            name: "roadmap.md",
            path: "/Work/Q3 Planning/roadmap.md",
            isDirectory: false,
            tags: ["#all", "#project", "#ideas"]
        ),
        initialContent: """
        # Q3 Product Roadmap

        Tags: #project #ideas

        - [x] Architecture Review & Technical Specifications
        - [x] Initial Filesystem Design
        - [ ] iOS Offline Storage & Documents Sandbox
        - [ ] Cross-device TLS sync validation

        Last updated: Today
        """,
        isPresented: .constant(true),
        onSave: { _ in }
    )
}
