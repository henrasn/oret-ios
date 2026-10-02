//
//  DeleteConfirmationModal.swift
//  OretIOS
//
//  Delete Note / Folder Confirmation Modal Molecule (Aged Manuscript theme)
//

import SwiftUI

public struct DeleteConfirmationModal: View {
    public let item: FileItem
    @Binding public var isPresented: Bool
    public let onConfirmDelete: () -> Void

    public init(
        item: FileItem,
        isPresented: Binding<Bool>,
        onConfirmDelete: @escaping () -> Void
    ) {
        self.item = item
        self._isPresented = isPresented
        self.onConfirmDelete = onConfirmDelete
    }

    public var body: some View {
        ZStack {
            // Dimmed backdrop overlay
            Color(hex: "#1E1C10")
                .opacity(0.55)
                .ignoresSafeArea()
                .onTapGesture {
                    isPresented = false
                }

            // Modal Card (340px width)
            VStack(spacing: 14) {
                // Header with circular error warning badge
                VStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(AgedManuscriptTheme.Colors.errorContainer)
                            .frame(width: 44, height: 44)
                            .overlay(
                                Circle()
                                    .stroke(AgedManuscriptTheme.Colors.errorRed.opacity(0.2), lineWidth: 1)
                            )

                        Image(systemName: "trash.fill")
                            .font(.system(size: 20))
                            .foregroundColor(AgedManuscriptTheme.Colors.errorRed)
                    }

                    Text(item.isDirectory ? "Delete Folder?" : "Delete Note?")
                        .font(AgedManuscriptTheme.Fonts.serifTitle(size: 18, weight: .semibold))
                        .foregroundColor(AgedManuscriptTheme.Colors.inkPrimary)
                }

                // File Details Card
                HStack(spacing: 10) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(AgedManuscriptTheme.Colors.parchment)
                            .frame(width: 32, height: 32)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(AgedManuscriptTheme.Colors.parchmentBorder, lineWidth: 1)
                            )

                        Image(systemName: item.isDirectory ? "folder" : "doc.text")
                            .font(.system(size: 16))
                            .foregroundColor(AgedManuscriptTheme.Colors.inkSecondary)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.name)
                            .font(AgedManuscriptTheme.Fonts.sansBody(size: 14, weight: .semibold))
                            .foregroundColor(AgedManuscriptTheme.Colors.inkPrimary)
                            .lineLimit(1)

                        Text("\(item.parentPath) • \(item.formattedSize.isEmpty ? "Directory" : item.formattedSize)")
                            .font(AgedManuscriptTheme.Fonts.monoCode(size: 11, weight: .regular))
                            .foregroundColor(AgedManuscriptTheme.Colors.inkSecondary)
                            .lineLimit(1)
                    }

                    Spacer()
                }
                .padding(10)
                .background(AgedManuscriptTheme.Colors.parchmentField)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(AgedManuscriptTheme.Colors.parchmentBorder, lineWidth: 1)
                )

                // Warning Copy
                Text(
                    item.isDirectory
                        ? "Are you sure you want to delete this folder and its contents? All files inside will be moved to trash."
                        : "Are you sure you want to delete this note? This file will be moved to the trash folder and will no longer sync with peer devices."
                )
                .font(AgedManuscriptTheme.Fonts.sansBody(size: 12))
                .foregroundColor(AgedManuscriptTheme.Colors.inkSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(2)
                .padding(.horizontal, 4)

                // Action Buttons (Cancel / Confirm Delete)
                HStack(spacing: 8) {
                    Button(action: {
                        isPresented = false
                    }) {
                        Text("Cancel")
                            .font(AgedManuscriptTheme.Fonts.sansBody(size: 13, weight: .medium))
                            .foregroundColor(AgedManuscriptTheme.Colors.inkPrimary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 40)
                            .background(AgedManuscriptTheme.Colors.parchment)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(AgedManuscriptTheme.Colors.parchmentBorder, lineWidth: 1)
                            )
                    }

                    Button(action: {
                        onConfirmDelete()
                        isPresented = false
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "trash")
                                .font(.system(size: 13, weight: .semibold))
                            Text(item.isDirectory ? "Delete Folder" : "Delete Note")
                                .font(AgedManuscriptTheme.Fonts.sansBody(size: 13, weight: .semibold))
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .foregroundColor(.white)
                        .background(AgedManuscriptTheme.Colors.errorRed)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .shadow(color: Color.black.opacity(0.08), radius: 2, y: 1)
                    }
                }
                .padding(.top, 4)
            }
            .padding(22)
            .frame(width: 340)
            .background(AgedManuscriptTheme.Colors.parchment)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(AgedManuscriptTheme.Colors.parchmentBorder, lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.18), radius: 20, y: 8)
        }
    }
}

#Preview("Delete Confirmation Modal") {
    DeleteConfirmationModal(
        item: FileItem(
            name: "roadmap.md",
            path: "/Work/Q3 Planning/roadmap.md",
            isDirectory: false,
            sizeBytes: 2457
        ),
        isPresented: .constant(true),
        onConfirmDelete: {}
    )
}
