//
//  CreateItemModal.swift
//  OretIOS
//
//  Create New Item Modal Molecule (Note / Folder Creation)
//

import SwiftUI

public struct CreateItemModal: View {
    @Binding public var isPresented: Bool
    public let availableFolders: [String]
    public let initialFolder: String
    public let initialIsFolder: Bool
    public let onCreate: (String, Bool, String) -> Void

    @State private var itemName: String = ""
    @State private var isFolder: Bool = false
    @State private var destinationFolder: String = "/"
    @State private var showFolderPicker: Bool = false

    public init(
        isPresented: Binding<Bool>,
        availableFolders: [String] = ["/", "/Work", "/Work/Q3 Planning", "/Personal"],
        initialFolder: String = "/",
        initialIsFolder: Bool = false,
        onCreate: @escaping (String, Bool, String) -> Void
    ) {
        self._isPresented = isPresented
        self.availableFolders = availableFolders
        self.initialFolder = initialFolder
        self.initialIsFolder = initialIsFolder
        self.onCreate = onCreate
        self._isFolder = State(initialValue: initialIsFolder)
        self._destinationFolder = State(initialValue: initialFolder)
    }

    private var cleanName: String {
        itemName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var resolvedPathPreview: String {
        let folder = destinationFolder.hasSuffix("/") ? destinationFolder : "\(destinationFolder)/"
        let ext = isFolder ? "" : (cleanName.hasSuffix(".md") ? "" : ".md")
        let finalFolder = destinationFolder == "/" ? "" : destinationFolder
        let display = cleanName.isEmpty ? "untitled" : cleanName
        return "\(finalFolder)/\(display)\(ext)"
    }

    public var body: some View {
        ZStack {
            // Dimmed parchment backdrop overlay
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
                            .frame(width: 34, height: 34)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(AgedManuscriptTheme.Colors.parchmentBorder, lineWidth: 1)
                            )

                        Image(systemName: "note.text.badge.plus")
                            .font(.system(size: 17, weight: .regular))
                            .foregroundColor(AgedManuscriptTheme.Colors.inkSecondary)
                    }

                    VStack(alignment: .leading, spacing: 3) {
                        Text("Create New Item")
                            .font(AgedManuscriptTheme.Fonts.serifTitle(size: 18, weight: .semibold))
                            .foregroundColor(AgedManuscriptTheme.Colors.inkPrimary)

                        Text("Add a note or directory to vault.")
                            .font(AgedManuscriptTheme.Fonts.sansLabel(size: 12, weight: .regular))
                            .foregroundColor(AgedManuscriptTheme.Colors.inkSecondary)
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

                // Type Toggle Segmented Control (Note .md vs Folder)
                HStack(spacing: 4) {
                    Button(action: {
                        isFolder = false
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "doc.text")
                                .font(.system(size: 13))
                            Text("Note (.md)")
                                .font(AgedManuscriptTheme.Fonts.sansLabel(size: 12, weight: .semibold))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 7)
                        .foregroundColor(!isFolder ? .white : AgedManuscriptTheme.Colors.inkSecondary)
                        .background(!isFolder ? AgedManuscriptTheme.Colors.inkDark : Color.clear)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                    .buttonStyle(PlainButtonStyle())

                    Button(action: {
                        isFolder = true
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "folder")
                                .font(.system(size: 13))
                            Text("Folder")
                                .font(AgedManuscriptTheme.Fonts.sansLabel(size: 12, weight: isFolder ? .semibold : .medium))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 7)
                        .foregroundColor(isFolder ? .white : AgedManuscriptTheme.Colors.inkSecondary)
                        .background(isFolder ? AgedManuscriptTheme.Colors.inkDark : Color.clear)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(3)
                .background(AgedManuscriptTheme.Colors.parchmentField)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(AgedManuscriptTheme.Colors.parchmentBorder, lineWidth: 1)
                )

                // Item Name Input
                VStack(alignment: .leading, spacing: 6) {
                    Text("Item Name")
                        .font(AgedManuscriptTheme.Fonts.sansLabel(size: 12, weight: .medium))
                        .foregroundColor(AgedManuscriptTheme.Colors.inkPrimary)

                    HStack(spacing: 8) {
                        Image(systemName: isFolder ? "folder" : "square.and.pencil")
                            .font(.system(size: 15))
                            .foregroundColor(AgedManuscriptTheme.Colors.inkMuted)

                        TextField(isFolder ? "folder-name" : "sprint-retrospective", text: $itemName)
                            .font(AgedManuscriptTheme.Fonts.sansBody(size: 14, weight: .medium))
                            .foregroundColor(AgedManuscriptTheme.Colors.inkPrimary)
                            .autocorrectionDisabled(true)
                            .textInputAutocapitalization(.never)

                        if !isFolder {
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
                }

                // Destination Folder Section
                VStack(alignment: .leading, spacing: 6) {
                    Text("Save In Folder")
                        .font(AgedManuscriptTheme.Fonts.sansLabel(size: 12, weight: .medium))
                        .foregroundColor(AgedManuscriptTheme.Colors.inkPrimary)

                    Menu {
                        ForEach(availableFolders, id: \.self) { folder in
                            Button(action: {
                                destinationFolder = folder
                            }) {
                                HStack {
                                    Text(folder)
                                    if folder == destinationFolder {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "folder")
                                .font(.system(size: 15))
                                .foregroundColor(AgedManuscriptTheme.Colors.crimsonAccent)

                            Text(destinationFolder.isEmpty ? "/" : destinationFolder)
                                .font(AgedManuscriptTheme.Fonts.monoCode(size: 12, weight: .medium))
                                .foregroundColor(AgedManuscriptTheme.Colors.inkPrimary)
                                .lineLimit(1)

                            Spacer()

                            HStack(spacing: 2) {
                                Text("Change")
                                    .font(AgedManuscriptTheme.Fonts.sansLabel(size: 11, weight: .medium))
                                    .foregroundColor(AgedManuscriptTheme.Colors.inkSecondary)
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 10, weight: .semibold))
                                    .foregroundColor(AgedManuscriptTheme.Colors.inkSecondary)
                            }
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(AgedManuscriptTheme.Colors.parchment)
                            .cornerRadius(4)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(AgedManuscriptTheme.Colors.parchmentBorder, lineWidth: 1)
                            )
                        }
                        .padding(.horizontal, 10)
                        .frame(height: 40)
                        .background(AgedManuscriptTheme.Colors.parchmentField)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(AgedManuscriptTheme.Colors.parchmentBorder, lineWidth: 1)
                        )
                    }
                }

                // Target Resolution Note
                HStack(spacing: 6) {
                    Image(systemName: "arrow.turn.down.right")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(AgedManuscriptTheme.Colors.statusGreen)

                    Text(resolvedPathPreview)
                        .font(AgedManuscriptTheme.Fonts.monoCode(size: 11, weight: .regular))
                        .foregroundColor(AgedManuscriptTheme.Colors.inkSecondary)
                        .lineLimit(1)
                }
                .padding(.horizontal, 4)

                // Action Buttons (Cancel / Create)
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
                        let finalName = isFolder ? cleanName : (cleanName.hasSuffix(".md") ? cleanName : "\(cleanName).md")
                        onCreate(finalName, isFolder, destinationFolder)
                        isPresented = false
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "plus")
                                .font(.system(size: 12, weight: .bold))
                            Text("Create")
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

#Preview("Create Item Modal") {
    CreateItemModal(
        isPresented: .constant(true),
        availableFolders: ["/", "/Work", "/Work/Q3 Planning", "/Personal"],
        initialFolder: "/Work/Q3 Planning",
        initialIsFolder: false,
        onCreate: { _, _, _ in }
    )
}
