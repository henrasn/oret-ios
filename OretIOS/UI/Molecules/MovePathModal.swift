//
//  MovePathModal.swift
//  OretIOS
//
//  Move Note / Folder Path Chooser Modal Molecule (Aged Manuscript theme)
//

import SwiftUI

public struct MovePathModal: View {
    public let item: FileItem
    public let availableFolders: [String]
    @Binding public var isPresented: Bool
    public let onMove: (String) -> Void

    @State private var selectedFolder: String

    public init(
        item: FileItem,
        availableFolders: [String] = ["/", "/Work", "/Personal", "/Archival Excerpts"],
        isPresented: Binding<Bool>,
        onMove: @escaping (String) -> Void
    ) {
        self.item = item
        self.availableFolders = availableFolders
        self._isPresented = isPresented
        self.onMove = onMove
        // Default selection to first non-current folder or root
        let initial = availableFolders.first(where: { $0 != item.parentPath }) ?? "/"
        self._selectedFolder = State(initialValue: initial)
    }

    private var destinationPreview: String {
        let folder = selectedFolder == "/" ? "" : selectedFolder
        return "\(folder)/\(item.name)"
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
                            .frame(width: 32, height: 32)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(AgedManuscriptTheme.Colors.parchmentBorder, lineWidth: 1)
                            )

                        Image(systemName: "folder.badge.gearshape")
                            .font(.system(size: 16))
                            .foregroundColor(AgedManuscriptTheme.Colors.inkSecondary)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.isDirectory ? "Move Folder" : "Move Note")
                            .font(AgedManuscriptTheme.Fonts.serifTitle(size: 18, weight: .semibold))
                            .foregroundColor(AgedManuscriptTheme.Colors.inkPrimary)

                        HStack(spacing: 3) {
                            Text("Select destination for")
                                .font(AgedManuscriptTheme.Fonts.sansLabel(size: 12))
                                .foregroundColor(AgedManuscriptTheme.Colors.inkSecondary)
                            Text(item.name)
                                .font(AgedManuscriptTheme.Fonts.sansLabel(size: 12, weight: .semibold))
                                .foregroundColor(AgedManuscriptTheme.Colors.inkPrimary)
                                .lineLimit(1)
                        }
                    }

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

                // Current Location Pill
                HStack(spacing: 4) {
                    Text("Current:")
                        .font(AgedManuscriptTheme.Fonts.monoCode(size: 11, weight: .regular))
                        .foregroundColor(AgedManuscriptTheme.Colors.inkMuted)
                    Text(item.parentPath)
                        .font(AgedManuscriptTheme.Fonts.monoCode(size: 11, weight: .medium))
                        .foregroundColor(AgedManuscriptTheme.Colors.inkPrimary)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(AgedManuscriptTheme.Colors.parchmentField)
                .clipShape(RoundedRectangle(cornerRadius: 4))
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(AgedManuscriptTheme.Colors.parchmentBorder, lineWidth: 1)
                )

                // Destination Folder Tree Picker
                ScrollView {
                    VStack(spacing: 4) {
                        ForEach(availableFolders, id: \.self) { folder in
                            let isCurrent = folder == item.parentPath
                            let isSelected = folder == selectedFolder

                            Button(action: {
                                if !isCurrent {
                                    selectedFolder = folder
                                }
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "folder")
                                        .font(.system(size: 15))
                                        .foregroundColor(
                                            isCurrent
                                                ? AgedManuscriptTheme.Colors.inkMuted
                                                : (isSelected ? AgedManuscriptTheme.Colors.inkPrimary : AgedManuscriptTheme.Colors.folderAmber)
                                        )

                                    Text(folder == "/" ? "/ (Vault Root)" : folder)
                                        .font(
                                            AgedManuscriptTheme.Fonts.sansBody(
                                                size: 13,
                                                weight: isSelected ? .semibold : .regular
                                            )
                                        )
                                        .foregroundColor(
                                            isCurrent
                                                ? AgedManuscriptTheme.Colors.inkMuted
                                                : AgedManuscriptTheme.Colors.inkPrimary
                                        )

                                    Spacer()

                                    if isCurrent {
                                        Text("Current location")
                                            .font(AgedManuscriptTheme.Fonts.sansLabel(size: 10, weight: .medium))
                                            .foregroundColor(AgedManuscriptTheme.Colors.inkMuted)
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(AgedManuscriptTheme.Colors.parchment)
                                            .cornerRadius(3)
                                    } else if isSelected {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 13, weight: .bold))
                                            .foregroundColor(AgedManuscriptTheme.Colors.inkPrimary)
                                    }
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 8)
                                .background(
                                    isSelected
                                        ? AgedManuscriptTheme.Colors.parchmentCard
                                        : Color.clear
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(
                                            isSelected ? AgedManuscriptTheme.Colors.inkDark : Color.clear,
                                            lineWidth: 1
                                        )
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                            .disabled(isCurrent)
                        }
                    }
                    .padding(6)
                }
                .frame(maxHeight: 180)
                .background(AgedManuscriptTheme.Colors.parchmentField)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(AgedManuscriptTheme.Colors.parchmentBorder, lineWidth: 1)
                )

                // Breadcrumb Destination Hint
                HStack(spacing: 4) {
                    Text("Destination:")
                        .font(AgedManuscriptTheme.Fonts.sansLabel(size: 11, weight: .regular))
                        .foregroundColor(AgedManuscriptTheme.Colors.inkSecondary)

                    Text(destinationPreview)
                        .font(AgedManuscriptTheme.Fonts.monoCode(size: 11, weight: .semibold))
                        .foregroundColor(AgedManuscriptTheme.Colors.inkPrimary)
                        .lineLimit(1)
                }
                .padding(.horizontal, 2)

                // Action Buttons (Cancel / Move Here)
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
                        guard selectedFolder != item.parentPath else { return }
                        onMove(selectedFolder)
                        isPresented = false
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "folder")
                                .font(.system(size: 13, weight: .semibold))
                            Text("Move Here")
                                .font(AgedManuscriptTheme.Fonts.sansBody(size: 13, weight: .semibold))
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .foregroundColor(.white)
                        .background(
                            selectedFolder == item.parentPath
                                ? AgedManuscriptTheme.Colors.inkMuted
                                : AgedManuscriptTheme.Colors.inkDark
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .shadow(color: Color.black.opacity(0.08), radius: 2, y: 1)
                    }
                    .disabled(selectedFolder == item.parentPath)
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

#Preview("Move Path Modal") {
    MovePathModal(
        item: FileItem(
            name: "roadmap.md",
            path: "/Work/Q3 Planning/roadmap.md",
            isDirectory: false
        ),
        availableFolders: ["/", "/Work", "/Work/Q3 Planning", "/Personal", "/Archival Excerpts"],
        isPresented: .constant(true),
        onMove: { _ in }
    )
}
