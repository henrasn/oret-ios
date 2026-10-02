//
//  DirectoryPathRow.swift
//  OretIOS
//
//  Directory Path Row Molecule for Workspace Directory Configuration
//

import SwiftUI

public struct DirectoryPathRow: View {
    @Binding public var folderName: String
    public var validationError: String?

    public init(
        folderName: Binding<String>,
        validationError: String? = nil
    ) {
        self._folderName = folderName
        self.validationError = validationError
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Label
            Text("LOCAL FOLDER NAME (LOCALPATH)")
                .font(AgedManuscriptTheme.Fonts.sansLabel(size: 11, weight: .semibold))
                .foregroundColor(AgedManuscriptTheme.Colors.inkSecondary)
                .tracking(0.8)

            // Input field container
            HStack(spacing: 12) {
                // Folder icon
                Image(systemName: "folder")
                    .font(.system(size: 17, weight: .regular))
                    .foregroundColor(AgedManuscriptTheme.Colors.inkMuted)

                // Monospace text field
                TextField("notes", text: $folderName)
                    .font(AgedManuscriptTheme.Fonts.monoCode(size: 14, weight: .medium))
                    .foregroundColor(AgedManuscriptTheme.Colors.inkPrimary)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)

                if !folderName.isEmpty && folderName != WorkspaceConfiguration.defaultFolderName {
                    Button(action: {
                        folderName = WorkspaceConfiguration.defaultFolderName
                    }) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(AgedManuscriptTheme.Colors.inkMuted)
                    }
                    .accessibilityLabel(Text("Reset to default folder"))
                }
            }
            .padding(.horizontal, 14)
            .frame(height: 48)
            .background(AgedManuscriptTheme.Colors.parchmentField)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(
                        validationError == nil
                            ? AgedManuscriptTheme.Colors.parchmentBorder
                            : AgedManuscriptTheme.Colors.crimsonAccent,
                        lineWidth: 1
                    )
            )

            // Dynamic Hint or Error
            if let error = validationError {
                HStack(alignment: .top, spacing: 6) {
                    Image(systemName: "exclamationmark.circle")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(AgedManuscriptTheme.Colors.crimsonAccent)
                    Text(error)
                        .font(AgedManuscriptTheme.Fonts.sansLabel(size: 12, weight: .medium))
                        .foregroundColor(AgedManuscriptTheme.Colors.crimsonAccent)
                }
                .padding(.top, 2)
            } else {
                HStack(alignment: .top, spacing: 6) {
                    Image(systemName: "info.circle")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(AgedManuscriptTheme.Colors.inkMuted)
                        .padding(.top, 1)

                    HStack(spacing: 4) {
                        Text("Folder path resolves securely to app storage:")
                            .font(AgedManuscriptTheme.Fonts.sansLabel(size: 12, weight: .regular))
                            .foregroundColor(AgedManuscriptTheme.Colors.inkSecondary)

                        Text(WorkspaceConfiguration.resolvedDisplayPath(for: folderName))
                            .font(AgedManuscriptTheme.Fonts.monoCode(size: 11, weight: .medium))
                            .foregroundColor(AgedManuscriptTheme.Colors.inkPrimary)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 1)
                            .background(Color(hex: "#EAE1CD"))
                            .cornerRadius(3)
                    }
                }
                .padding(.top, 2)
            }
        }
    }
}

#Preview {
    VStack(spacing: 24) {
        DirectoryPathRow(
            folderName: .constant("notes"),
            validationError: nil
        )

        DirectoryPathRow(
            folderName: .constant("../invalid_folder"),
            validationError: "Path traversal (..) is not allowed"
        )
    }
    .padding()
    .agedManuscriptBackground()
}
