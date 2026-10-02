//
//  WorkspaceConfiguration.swift
//  OretIOS
//
//  Workspace Directory Configuration and Path Validation
//

import Foundation

public struct WorkspacePathValidation: Equatable {
    public let isValid: Bool
    public let errorMessage: String?

    public static let valid = WorkspacePathValidation(isValid: true, errorMessage: nil)
    public static func invalid(_ message: String) -> WorkspacePathValidation {
        WorkspacePathValidation(isValid: false, errorMessage: message)
    }
}

public struct WorkspaceConfiguration {
    public static let defaultFolderName = "notes"

    /// Validates a relative folder name according to sandbox and security specifications
    public static func validate(folderName: String) -> WorkspacePathValidation {
        let trimmed = folderName.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmed.isEmpty {
            return .invalid("Folder name cannot be empty")
        }

        if trimmed.contains("..") {
            return .invalid("Path traversal (..) is not allowed")
        }

        if trimmed.hasPrefix("/") || trimmed.hasPrefix("\\") {
            return .invalid("Path must be a relative folder name")
        }

        let illegalCharacters = CharacterSet(charactersIn: ":*?\"<>|\0")
        if trimmed.rangeOfCharacter(from: illegalCharacters) != nil {
            return .invalid("Folder name contains invalid characters")
        }

        return .valid
    }

    /// Resolves the human-readable sandbox path string for UI hints
    public static func resolvedDisplayPath(for folderName: String) -> String {
        let cleanName = folderName.trimmingCharacters(in: .whitespacesAndNewlines)
        return "Documents/\(cleanName.isEmpty ? defaultFolderName : cleanName)"
    }
}
