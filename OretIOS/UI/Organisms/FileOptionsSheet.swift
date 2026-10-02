//
//  FileOptionsSheet.swift
//  OretIOS
//
//  File Options Bottom Sheet Organism (Aged Manuscript theme)
//

import SwiftUI

public struct FileOptionsSheet: View {
    public let item: FileItem
    @Binding public var isPresented: Bool
    public let onRename: () -> Void
    public let onDuplicate: () -> Void
    public let onMove: () -> Void
    public let onDelete: () -> Void

    public init(
        item: FileItem,
        isPresented: Binding<Bool>,
        onRename: @escaping () -> Void,
        onDuplicate: @escaping () -> Void,
        onMove: @escaping () -> Void,
        onDelete: @escaping () -> Void
    ) {
        self.item = item
        self._isPresented = isPresented
        self.onRename = onRename
        self.onDuplicate = onDuplicate
        self.onMove = onMove
        self.onDelete = onDelete
    }

    public var body: some View {
        ZStack(alignment: .bottom) {
            // Dimmed backdrop overlay
            Color(hex: "#1E1C10")
                .opacity(0.45)
                .ignoresSafeArea()
                .onTapGesture {
                    isPresented = false
                }

            // Bottom sheet container
            VStack(spacing: 0) {
                // Grab Handle
                Capsule()
                    .fill(AgedManuscriptTheme.Colors.parchmentBorder)
                    .frame(width: 40, height: 4)
                    .padding(.top, 10)
                    .padding(.bottom, 12)

                // Selected File Header
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(AgedManuscriptTheme.Colors.parchmentField)
                            .frame(width: 38, height: 38)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(AgedManuscriptTheme.Colors.parchmentBorder, lineWidth: 1)
                            )

                        Image(systemName: item.sfSymbolName)
                            .font(.system(size: 18, weight: .regular))
                            .foregroundColor(
                                item.isDirectory
                                    ? AgedManuscriptTheme.Colors.folderAmber
                                    : AgedManuscriptTheme.Colors.inkPrimary
                            )
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.name)
                            .font(AgedManuscriptTheme.Fonts.sansBody(size: 16, weight: .semibold))
                            .foregroundColor(AgedManuscriptTheme.Colors.inkPrimary)
                            .lineLimit(1)

                        Text(item.parentPath)
                            .font(AgedManuscriptTheme.Fonts.monoCode(size: 12, weight: .regular))
                            .foregroundColor(AgedManuscriptTheme.Colors.inkSecondary)
                            .lineLimit(1)
                    }

                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 12)

                Divider()
                    .background(AgedManuscriptTheme.Colors.parchmentBorder.opacity(0.5))

                // Options List
                VStack(spacing: 0) {
                    ActionSheetRow(
                        icon: "pencil",
                        title: item.isDirectory ? "Rename Folder" : "Rename Note",
                        action: {
                            isPresented = false
                            onRename()
                        }
                    )

                    ActionSheetRow(
                        icon: "doc.on.doc",
                        title: item.isDirectory ? "Duplicate Folder" : "Duplicate Note",
                        action: {
                            isPresented = false
                            onDuplicate()
                        }
                    )

                    ActionSheetRow(
                        icon: "folder",
                        title: "Move to Another Folder",
                        action: {
                            isPresented = false
                            onMove()
                        }
                    )

                    ActionSheetRow(
                        icon: "trash",
                        title: item.isDirectory ? "Delete Folder" : "Delete Note",
                        isDestructive: true,
                        action: {
                            isPresented = false
                            onDelete()
                        }
                    )
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 4)

                // Cancel Button
                Button(action: {
                    isPresented = false
                }) {
                    Text("Cancel")
                        .font(AgedManuscriptTheme.Fonts.sansBody(size: 14, weight: .medium))
                        .foregroundColor(AgedManuscriptTheme.Colors.inkPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(AgedManuscriptTheme.Colors.parchmentField)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(AgedManuscriptTheme.Colors.parchmentBorder, lineWidth: 1)
                        )
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
            .frame(maxWidth: .infinity)
            .background(AgedManuscriptTheme.Colors.parchment)
            .clipShape(
                UnevenRoundedRectangle(
                    topLeadingRadius: 18,
                    bottomLeadingRadius: 0,
                    bottomTrailingRadius: 0,
                    topTrailingRadius: 18
                )
            )
            .overlay(
                UnevenRoundedRectangle(
                    topLeadingRadius: 18,
                    bottomLeadingRadius: 0,
                    bottomTrailingRadius: 0,
                    topTrailingRadius: 18
                )
                .stroke(AgedManuscriptTheme.Colors.parchmentBorder, lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.12), radius: 16, y: -4)
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

#Preview("File Options Sheet") {
    ZStack {
        AgedManuscriptTheme.Colors.parchment
            .ignoresSafeArea()

        FileOptionsSheet(
            item: FileItem(
                name: "roadmap.md",
                path: "/Work/Q3 Planning/roadmap.md",
                isDirectory: false
            ),
            isPresented: .constant(true),
            onRename: {},
            onDuplicate: {},
            onMove: {},
            onDelete: {}
        )
    }
}
