//
//  RenameModal.swift
//  OretIOS
//
//  Rename Note / Folder Modal Molecule (Aged Manuscript theme)
//

import SwiftUI

public struct RenameModal: View {
    public let item: FileItem
    @Binding public var isPresented: Bool
    public let onRename: (String) -> Void

    @State private var newName: String = ""

    public init(
        item: FileItem,
        isPresented: Binding<Bool>,
        onRename: @escaping (String) -> Void
    ) {
        self.item = item
        self._isPresented = isPresented
        self.onRename = onRename
        self._newName = State(initialValue: item.nameWithoutExtension)
    }

    private var cleanName: String {
        newName.trimmingCharacters(in: .whitespacesAndNewlines)
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
            VStack(alignment: .leading, spacing: 14) {
                // Header Row
                HStack(alignment: .top, spacing: 10) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(AgedManuscriptTheme.Colors.parchmentField)
                            .frame(width: 30, height: 30)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(AgedManuscriptTheme.Colors.parchmentBorder, lineWidth: 1)
                            )

                        Image(systemName: "pencil")
                            .font(.system(size: 15, weight: .regular))
                            .foregroundColor(AgedManuscriptTheme.Colors.inkSecondary)
                    }

                    Text(item.isDirectory ? "Rename Folder" : "Rename Note")
                        .font(AgedManuscriptTheme.Fonts.serifTitle(size: 18, weight: .semibold))
                        .foregroundColor(AgedManuscriptTheme.Colors.inkPrimary)

                    Spacer()

                    Button(action: {
                        isPresented = false
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(AgedManuscriptTheme.Colors.inkSecondary)
                            .frame(width: 28, height: 28)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(PlainButtonStyle())
                }

                // Folder Location Subtitle
                HStack(spacing: 5) {
                    Image(systemName: "folder")
                        .font(.system(size: 13))
                        .foregroundColor(AgedManuscriptTheme.Colors.inkMuted)

                    Text("Folder location:")
                        .font(AgedManuscriptTheme.Fonts.sansLabel(size: 12, weight: .regular))
                        .foregroundColor(AgedManuscriptTheme.Colors.inkSecondary)

                    Text(item.parentPath)
                        .font(AgedManuscriptTheme.Fonts.monoCode(size: 12, weight: .medium))
                        .foregroundColor(AgedManuscriptTheme.Colors.inkPrimary)
                        .lineLimit(1)
                }

                // Input Section
                VStack(alignment: .leading, spacing: 6) {
                    Text(item.isDirectory ? "Folder Name" : "Note Name")
                        .font(AgedManuscriptTheme.Fonts.sansLabel(size: 12, weight: .medium))
                        .foregroundColor(AgedManuscriptTheme.Colors.inkPrimary)

                    HStack(spacing: 8) {
                        Image(systemName: item.isDirectory ? "folder" : "doc.text")
                            .font(.system(size: 16))
                            .foregroundColor(AgedManuscriptTheme.Colors.inkMuted)

                        TextField("roadmap-2024", text: $newName)
                            .font(AgedManuscriptTheme.Fonts.sansBody(size: 14, weight: .medium))
                            .foregroundColor(AgedManuscriptTheme.Colors.inkPrimary)
                            .autocorrectionDisabled(true)
                            .textInputAutocapitalization(.never)

                        if !item.isDirectory && item.fileExtension == "md" {
                            Text(".md")
                                .font(AgedManuscriptTheme.Fonts.monoCode(size: 11, weight: .medium))
                                .foregroundColor(AgedManuscriptTheme.Colors.inkSecondary)
                                .padding(.horizontal, 5)
                                .padding(.vertical, 2)
                                .background(Color(hex: "#EFE8D5"))
                                .cornerRadius(4)
                        }
                    }
                    .padding(.horizontal, 10)
                    .frame(height: 42)
                    .background(AgedManuscriptTheme.Colors.parchmentField)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(AgedManuscriptTheme.Colors.inkDark, lineWidth: 1.5)
                    )

                    if !item.isDirectory && item.fileExtension == "md" {
                        HStack(spacing: 4) {
                            Image(systemName: "info.circle")
                                .font(.system(size: 11))
                                .foregroundColor(AgedManuscriptTheme.Colors.inkMuted)

                            Text("Extension")
                                .font(AgedManuscriptTheme.Fonts.sansLabel(size: 11))
                                .foregroundColor(AgedManuscriptTheme.Colors.inkSecondary)

                            Text(".md")
                                .font(AgedManuscriptTheme.Fonts.monoCode(size: 10, weight: .medium))
                                .foregroundColor(AgedManuscriptTheme.Colors.inkPrimary)
                                .padding(.horizontal, 3)
                                .padding(.vertical, 1)
                                .background(AgedManuscriptTheme.Colors.parchmentField)
                                .cornerRadius(2)

                            Text("is preserved automatically.")
                                .font(AgedManuscriptTheme.Fonts.sansLabel(size: 11))
                                .foregroundColor(AgedManuscriptTheme.Colors.inkSecondary)
                        }
                        .padding(.top, 2)
                    }
                }

                // Action Buttons (Cancel / Rename)
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
                        guard !cleanName.isEmpty else { return }
                        let finalName: String
                        if item.isDirectory {
                            finalName = cleanName
                        } else if !item.fileExtension.isEmpty {
                            finalName = "\(cleanName).\(item.fileExtension)"
                        } else {
                            finalName = cleanName
                        }
                        onRename(finalName)
                        isPresented = false
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark")
                                .font(.system(size: 12, weight: .bold))
                            Text("Rename")
                                .font(AgedManuscriptTheme.Fonts.sansBody(size: 13, weight: .semibold))
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .foregroundColor(.white)
                        .background(cleanName.isEmpty ? AgedManuscriptTheme.Colors.inkMuted : AgedManuscriptTheme.Colors.inkDark)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .shadow(color: Color.black.opacity(0.08), radius: 2, y: 1)
                    }
                    .disabled(cleanName.isEmpty)
                }
                .padding(.top, 4)
            }
            .padding(20)
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

#Preview("Rename Modal") {
    RenameModal(
        item: FileItem(
            name: "roadmap.md",
            path: "/Work/Q3 Planning/roadmap.md",
            isDirectory: false
        ),
        isPresented: .constant(true),
        onRename: { _ in }
    )
}
