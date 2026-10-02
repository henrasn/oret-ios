//
//  WorkspaceFileManager.swift
//  OretIOS
//
//  Local Sandboxed Filesystem Service for Documents/notes
//  Handles hierarchical tree enumeration, Markdown CRUD, security boundaries,
//  and protected path isolation (.syncstore/).
//

import Foundation

#if canImport(SharedLogic)
import SharedLogic
#endif

// MARK: - Workspace Filesystem Error Types (Conforming to Stitch Specification)

public enum WorkspaceFilesystemError: LocalizedError, Equatable {
    case workspaceLocked
    case itemNotFound(path: String)
    case itemAlreadyExists(path: String)
    case invalidName(reason: String)
    case pathTraversal(path: String)
    case protectedPath(path: String)
    case circularMove(source: String, destination: String)
    case ioError(description: String)

    public var errorDescription: String? {
        switch self {
        case .workspaceLocked:
            return "Workspace is in Read-Only mode during active sync."
        case .itemNotFound(let path):
            return "Item not found at path: \(path)"
        case .itemAlreadyExists(let path):
            return "An item already exists at path: \(path)"
        case .invalidName(let reason):
            return "Invalid item name: \(reason)"
        case .pathTraversal(let path):
            return "Path traversal detected: \(path)"
        case .protectedPath(let path):
            return "Access to protected directory '\(path)' is forbidden."
        case .circularMove(let source, let dest):
            return "Cannot move folder '\(source)' into its own subfolder '\(dest)'."
        case .ioError(let description):
            return "Filesystem I/O error: \(description)"
        }
    }
}

// MARK: - Workspace Filesystem Protocol

public protocol WorkspaceFilesystemProtocol: AnyObject {
    var workspaceName: String { get }
    var baseURL: URL { get }
    var isSyncing: Bool { get set }

    func ensureWorkspaceExists() throws
    func seedInitialContentIfEmpty() throws
    func listTree() throws -> [FileItem]
    func readFile(at relativePath: String) throws -> String
    func saveFile(at relativePath: String, content: String) throws
    func createFile(name: String, in relativeParentPath: String, initialContent: String?) throws -> FileItem
    func createFolder(name: String, in relativeParentPath: String) throws -> FileItem
    func renameItem(at relativePath: String, to newName: String) throws -> FileItem
    func moveItem(from sourceRelativePath: String, to targetParentPath: String) throws -> FileItem
    func duplicateItem(at relativePath: String) throws -> FileItem
    func deleteItem(at relativePath: String) throws
    func savePendingRevision(revision: String, resolutions: [String: String]) throws -> URL
    func readPendingRevision() -> [String: Any]?
    func clearPendingRevision()
}

// MARK: - Workspace File Manager Implementation

public final class WorkspaceFileManager: WorkspaceFilesystemProtocol {
    public let workspaceName: String
    public let baseURL: URL
    public let fileManager: FileManager
    public var isSyncing: Bool = false

    public init(
        workspaceName: String = "notes",
        fileManager: FileManager = .default,
        rootDirectoryURL: URL? = nil
    ) {
        let cleanName = workspaceName.trimmingCharacters(in: .whitespacesAndNewlines)
        let resolvedName = cleanName.isEmpty ? "notes" : cleanName
        self.workspaceName = resolvedName
        self.fileManager = fileManager

        if let explicitRoot = rootDirectoryURL {
            self.baseURL = explicitRoot
        } else {
            let documents = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
                ?? URL(fileURLWithPath: NSTemporaryDirectory())
            self.baseURL = documents.appendingPathComponent(resolvedName, isDirectory: true)
        }
    }

    // MARK: - Workspace Lifecycle & Seeding

    public func ensureWorkspaceExists() throws {
        var isDir: ObjCBool = false
        if !fileManager.fileExists(atPath: baseURL.path, isDirectory: &isDir) {
            do {
                try fileManager.createDirectory(at: baseURL, withIntermediateDirectories: true)
            } catch {
                throw WorkspaceFilesystemError.ioError(description: error.localizedDescription)
            }
            try seedInitialContentIfEmpty()
        } else if !isDir.boolValue {
            throw WorkspaceFilesystemError.ioError(description: "Path exists but is not a directory: \(baseURL.path)")
        } else {
            // Check if directory is completely empty
            let contents = (try? fileManager.contentsOfDirectory(atPath: baseURL.path)) ?? []
            let nonHidden = contents.filter { !$0.hasPrefix(".") }
            if nonHidden.isEmpty {
                try seedInitialContentIfEmpty()
            }
        }
    }

    public func seedInitialContentIfEmpty() throws {
        // Seed canonical starter hierarchy matching Stitch Aged Manuscript specs
        let workURL = baseURL.appendingPathComponent("Work", isDirectory: true)
        let q3URL = workURL.appendingPathComponent("Q3 Planning", isDirectory: true)
        let personalURL = baseURL.appendingPathComponent("Personal", isDirectory: true)

        try? fileManager.createDirectory(at: q3URL, withIntermediateDirectories: true)
        try? fileManager.createDirectory(at: personalURL, withIntermediateDirectories: true)

        let initialNotes: [(URL, String)] = [
            (
                q3URL.appendingPathComponent("roadmap.md"),
                """
                # Q3 Product Roadmap

                Tags: #project #ideas

                - [x] Architecture Review & Technical Specifications
                - [x] Initial Filesystem Design
                - [ ] iOS Offline Storage & Documents Sandbox
                - [ ] Cross-device TLS sync validation

                Last updated: Today
                """
            ),
            (
                q3URL.appendingPathComponent("budget.md"),
                """
                # Q3 Budget Allocation

                Tags: #project

                | Category | Allocated | Spent | Status |
                |---|---|---|---|
                | Infrastructure | $12,000 | $8,500 | On Track |
                | Tooling & CI | $4,500 | $3,200 | Good |
                | Contingency | $1,932 | $0 | Reserved |

                Total allocated: $18,432
                """
            ),
            (
                workURL.appendingPathComponent("team-meeting.md"),
                """
                # Team Meeting Notes

                Tags: #meeting

                ## Agenda
                1. Milestone 2: File Explorer & Document Storage review
                2. Android & iOS Native parity
                3. Next steps on conflict resolution
                """
            ),
            (
                personalURL.appendingPathComponent("journal.md"),
                """
                # Daily Journal

                Tags: #ideas

                Reflections on clean architecture and mobile file systems.
                Maintaining high code quality and strict invariant testing.
                """
            ),
            (
                baseURL.appendingPathComponent("quick-scratchpad.md"),
                """
                # Quick Scratchpad

                Tags: #todo

                - [ ] Verify directory tree hierarchy
                - [ ] Test rename, move, duplicate, and delete operations
                - [ ] Validate markdown saving
                """
            ),
            (
                baseURL.appendingPathComponent("reading-digest.md"),
                """
                # Reading Digest

                Tags: #ideas

                Links and excerpts from weekly engineering papers.
                Local-first software architectures and CRDT synchronization patterns.
                """
            )
        ]

        for (url, content) in initialNotes {
            if !fileManager.fileExists(atPath: url.path) {
                let data = Data(content.utf8)
                try? data.write(to: url, options: .atomic)
            }
        }
    }

    // MARK: - Tree Hierarchy Reading (Excluding .syncstore/)

    public func listTree() throws -> [FileItem] {
        guard fileManager.fileExists(atPath: baseURL.path) else {
            return []
        }
        return try scanDirectory(at: baseURL, relativePrefix: "")
    }

    private func scanDirectory(at dirURL: URL, relativePrefix: String) throws -> [FileItem] {
        let contents = try fileManager.contentsOfDirectory(
            at: dirURL,
            includingPropertiesForKeys: [.isDirectoryKey, .fileSizeKey, .contentModificationDateKey],
            options: [.skipsHiddenFiles]
        )

        var items: [FileItem] = []

        for itemURL in contents {
            let name = itemURL.lastPathComponent

            // Security & Safety: Strictly exclude .syncstore and hidden files
            if name == ".syncstore" || name.hasPrefix(".") {
                continue
            }

            let resourceValues = try itemURL.resourceValues(forKeys: [.isDirectoryKey, .fileSizeKey, .contentModificationDateKey])
            let isDirectory = resourceValues.isDirectory ?? false
            let relPath = relativePrefix.isEmpty ? "/\(name)" : "\(relativePrefix)/\(name)"
            let mDate = resourceValues.contentModificationDate ?? Date()

            if isDirectory {
                let children = try scanDirectory(at: itemURL, relativePrefix: relPath)
                let folderItem = FileItem(
                    id: relPath,
                    name: name,
                    path: relPath,
                    isDirectory: true,
                    sizeBytes: 0,
                    modifiedAt: mDate,
                    tags: ["#all"],
                    isExpanded: true,
                    children: children
                )
                items.append(folderItem)
            } else {
                let size = Int64(resourceValues.fileSize ?? 0)
                var tags = ["#all"]
                if itemURL.pathExtension.lowercased() == "md" {
                    if let content = try? String(contentsOf: itemURL, encoding: .utf8) {
                        tags = WorkspaceFileManager.extractTags(from: content)
                    }
                }

                let fileItem = FileItem(
                    id: relPath,
                    name: name,
                    path: relPath,
                    isDirectory: false,
                    sizeBytes: size,
                    modifiedAt: mDate,
                    tags: tags,
                    isExpanded: false,
                    children: []
                )
                items.append(fileItem)
            }
        }

        // Sort: Folders first alphabetically, then files alphabetically
        return items.sorted { first, second in
            if first.isDirectory && !second.isDirectory {
                return true
            } else if !first.isDirectory && second.isDirectory {
                return false
            } else {
                return first.name.localizedCaseInsensitiveCompare(second.name) == .orderedAscending
            }
        }
    }

    // MARK: - File & Folder CRUD Operations

    public func createFile(
        name: String,
        in relativeParentPath: String,
        initialContent: String? = nil
    ) throws -> FileItem {
        guard !isSyncing else { throw WorkspaceFilesystemError.workspaceLocked }

        let validName = try validateItemName(name)
        let finalFileName = validName.lowercased().hasSuffix(".md") ? validName : "\(validName).md"

        let parentURL = try resolveSecureURL(relativePath: relativeParentPath)
        var isDir: ObjCBool = false
        guard fileManager.fileExists(atPath: parentURL.path, isDirectory: &isDir), isDir.boolValue else {
            throw WorkspaceFilesystemError.itemNotFound(path: relativeParentPath)
        }

        let fileURL = parentURL.appendingPathComponent(finalFileName)
        if fileManager.fileExists(atPath: fileURL.path) {
            let relDisplay = makeRelativeDisplayPath(for: fileURL)
            throw WorkspaceFilesystemError.itemAlreadyExists(path: relDisplay)
        }

        let heading = (finalFileName as NSString).deletingPathExtension
        let body = initialContent ?? "# \(heading)\n\n"
        guard let data = body.data(using: .utf8) else {
            throw WorkspaceFilesystemError.ioError(description: "Failed to encode Markdown content.")
        }

        do {
            try data.write(to: fileURL, options: .atomic)
        } catch {
            throw WorkspaceFilesystemError.ioError(description: error.localizedDescription)
        }

        let displayPath = makeRelativeDisplayPath(for: fileURL)
        let tags = WorkspaceFileManager.extractTags(from: body)

        return FileItem(
            id: displayPath,
            name: finalFileName,
            path: displayPath,
            isDirectory: false,
            sizeBytes: Int64(data.count),
            modifiedAt: Date(),
            tags: tags,
            isExpanded: false,
            children: []
        )
    }

    public func createFolder(name: String, in relativeParentPath: String) throws -> FileItem {
        guard !isSyncing else { throw WorkspaceFilesystemError.workspaceLocked }

        let validName = try validateItemName(name)
        let parentURL = try resolveSecureURL(relativePath: relativeParentPath)
        var isDir: ObjCBool = false
        guard fileManager.fileExists(atPath: parentURL.path, isDirectory: &isDir), isDir.boolValue else {
            throw WorkspaceFilesystemError.itemNotFound(path: relativeParentPath)
        }

        let folderURL = parentURL.appendingPathComponent(validName, isDirectory: true)
        if fileManager.fileExists(atPath: folderURL.path) {
            let relDisplay = makeRelativeDisplayPath(for: folderURL)
            throw WorkspaceFilesystemError.itemAlreadyExists(path: relDisplay)
        }

        do {
            try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: false)
        } catch {
            throw WorkspaceFilesystemError.ioError(description: error.localizedDescription)
        }

        let displayPath = makeRelativeDisplayPath(for: folderURL)
        return FileItem(
            id: displayPath,
            name: validName,
            path: displayPath,
            isDirectory: true,
            sizeBytes: 0,
            modifiedAt: Date(),
            tags: ["#all"],
            isExpanded: true,
            children: []
        )
    }

    public func renameItem(at relativePath: String, to newName: String) throws -> FileItem {
        guard !isSyncing else { throw WorkspaceFilesystemError.workspaceLocked }

        let sourceURL = try resolveSecureURL(relativePath: relativePath)
        var isDir: ObjCBool = false
        guard fileManager.fileExists(atPath: sourceURL.path, isDirectory: &isDir) else {
            throw WorkspaceFilesystemError.itemNotFound(path: relativePath)
        }

        let validName = try validateItemName(newName)
        let finalName: String
        if isDir.boolValue {
            finalName = validName
        } else {
            finalName = validName.lowercased().hasSuffix(".md") ? validName : "\(validName).md"
        }

        let parentURL = sourceURL.deletingLastPathComponent()
        let destURL = parentURL.appendingPathComponent(finalName, isDirectory: isDir.boolValue)

        if destURL.path != sourceURL.path && fileManager.fileExists(atPath: destURL.path) {
            let relDisplay = makeRelativeDisplayPath(for: destURL)
            throw WorkspaceFilesystemError.itemAlreadyExists(path: relDisplay)
        }

        do {
            try fileManager.moveItem(at: sourceURL, to: destURL)
        } catch {
            throw WorkspaceFilesystemError.ioError(description: error.localizedDescription)
        }

        let displayPath = makeRelativeDisplayPath(for: destURL)
        let attrs = (try? fileManager.attributesOfItem(atPath: destURL.path)) ?? [:]
        let size = (attrs[.size] as? NSNumber)?.int64Value ?? 0
        let mDate = (attrs[.modificationDate] as? Date) ?? Date()

        var tags = ["#all"]
        if !isDir.boolValue {
            if let content = try? String(contentsOf: destURL, encoding: .utf8) {
                tags = WorkspaceFileManager.extractTags(from: content)
            }
        }

        return FileItem(
            id: displayPath,
            name: finalName,
            path: displayPath,
            isDirectory: isDir.boolValue,
            sizeBytes: size,
            modifiedAt: mDate,
            tags: tags,
            isExpanded: isDir.boolValue,
            children: []
        )
    }

    public func moveItem(from sourceRelativePath: String, to targetParentPath: String) throws -> FileItem {
        guard !isSyncing else { throw WorkspaceFilesystemError.workspaceLocked }

        let sourceURL = try resolveSecureURL(relativePath: sourceRelativePath)
        var isDir: ObjCBool = false
        guard fileManager.fileExists(atPath: sourceURL.path, isDirectory: &isDir) else {
            throw WorkspaceFilesystemError.itemNotFound(path: sourceRelativePath)
        }

        let targetParentURL = try resolveSecureURL(relativePath: targetParentPath)
        var targetIsDir: ObjCBool = false
        guard fileManager.fileExists(atPath: targetParentURL.path, isDirectory: &targetIsDir), targetIsDir.boolValue else {
            throw WorkspaceFilesystemError.itemNotFound(path: targetParentPath)
        }

        // Circular move check: folder cannot be moved into its own descendant
        if isDir.boolValue {
            let canonicalSource = sourceURL.standardizedFileURL.path
            let canonicalTargetParent = targetParentURL.standardizedFileURL.path
            if canonicalTargetParent == canonicalSource || canonicalTargetParent.hasPrefix(canonicalSource + "/") {
                throw WorkspaceFilesystemError.circularMove(source: sourceRelativePath, destination: targetParentPath)
            }
        }

        let destURL = targetParentURL.appendingPathComponent(sourceURL.lastPathComponent, isDirectory: isDir.boolValue)
        if destURL.path != sourceURL.path && fileManager.fileExists(atPath: destURL.path) {
            let relDisplay = makeRelativeDisplayPath(for: destURL)
            throw WorkspaceFilesystemError.itemAlreadyExists(path: relDisplay)
        }

        do {
            try fileManager.moveItem(at: sourceURL, to: destURL)
        } catch {
            throw WorkspaceFilesystemError.ioError(description: error.localizedDescription)
        }

        let displayPath = makeRelativeDisplayPath(for: destURL)
        let attrs = (try? fileManager.attributesOfItem(atPath: destURL.path)) ?? [:]
        let size = (attrs[.size] as? NSNumber)?.int64Value ?? 0
        let mDate = (attrs[.modificationDate] as? Date) ?? Date()

        var tags = ["#all"]
        if !isDir.boolValue {
            if let content = try? String(contentsOf: destURL, encoding: .utf8) {
                tags = WorkspaceFileManager.extractTags(from: content)
            }
        }

        return FileItem(
            id: displayPath,
            name: destURL.lastPathComponent,
            path: displayPath,
            isDirectory: isDir.boolValue,
            sizeBytes: size,
            modifiedAt: mDate,
            tags: tags,
            isExpanded: isDir.boolValue,
            children: []
        )
    }

    public func duplicateItem(at relativePath: String) throws -> FileItem {
        guard !isSyncing else { throw WorkspaceFilesystemError.workspaceLocked }

        let sourceURL = try resolveSecureURL(relativePath: relativePath)
        var isDir: ObjCBool = false
        guard fileManager.fileExists(atPath: sourceURL.path, isDirectory: &isDir) else {
            throw WorkspaceFilesystemError.itemNotFound(path: relativePath)
        }

        let parentURL = sourceURL.deletingLastPathComponent()
        let originalName = sourceURL.lastPathComponent
        let ext = (originalName as NSString).pathExtension
        let base = isDir.boolValue ? originalName : (originalName as NSString).deletingPathExtension

        // Generate candidate name: name-copy.md, name-copy-2.md, etc.
        var counter = 1
        var candidateName = ext.isEmpty ? "\(base)-copy" : "\(base)-copy.\(ext)"
        var destURL = parentURL.appendingPathComponent(candidateName, isDirectory: isDir.boolValue)

        while fileManager.fileExists(atPath: destURL.path) {
            counter += 1
            candidateName = ext.isEmpty ? "\(base)-copy-\(counter)" : "\(base)-copy-\(counter).\(ext)"
            destURL = parentURL.appendingPathComponent(candidateName, isDirectory: isDir.boolValue)
        }

        do {
            try fileManager.copyItem(at: sourceURL, to: destURL)
        } catch {
            throw WorkspaceFilesystemError.ioError(description: error.localizedDescription)
        }

        let displayPath = makeRelativeDisplayPath(for: destURL)
        let attrs = (try? fileManager.attributesOfItem(atPath: destURL.path)) ?? [:]
        let size = (attrs[.size] as? NSNumber)?.int64Value ?? 0
        let mDate = (attrs[.modificationDate] as? Date) ?? Date()

        var tags = ["#all"]
        if !isDir.boolValue {
            if let content = try? String(contentsOf: destURL, encoding: .utf8) {
                tags = WorkspaceFileManager.extractTags(from: content)
            }
        }

        return FileItem(
            id: displayPath,
            name: candidateName,
            path: displayPath,
            isDirectory: isDir.boolValue,
            sizeBytes: size,
            modifiedAt: mDate,
            tags: tags,
            isExpanded: isDir.boolValue,
            children: []
        )
    }

    public func deleteItem(at relativePath: String) throws {
        guard !isSyncing else { throw WorkspaceFilesystemError.workspaceLocked }

        let targetURL = try resolveSecureURL(relativePath: relativePath)

        // Safety Invariant: Workspace root itself cannot be deleted
        if targetURL.standardizedFileURL.path == baseURL.standardizedFileURL.path {
            throw WorkspaceFilesystemError.protectedPath(path: relativePath)
        }

        guard fileManager.fileExists(atPath: targetURL.path) else {
            throw WorkspaceFilesystemError.itemNotFound(path: relativePath)
        }

        do {
            try fileManager.removeItem(at: targetURL)
        } catch {
            throw WorkspaceFilesystemError.ioError(description: error.localizedDescription)
        }
    }

    // MARK: - Reading & Saving Markdown Content

    public func readFile(at relativePath: String) throws -> String {
        let fileURL = try resolveSecureURL(relativePath: relativePath)
        var isDir: ObjCBool = false
        guard fileManager.fileExists(atPath: fileURL.path, isDirectory: &isDir), !isDir.boolValue else {
            throw WorkspaceFilesystemError.itemNotFound(path: relativePath)
        }

        do {
            return try String(contentsOf: fileURL, encoding: .utf8)
        } catch {
            throw WorkspaceFilesystemError.ioError(description: error.localizedDescription)
        }
    }

    public func saveFile(at relativePath: String, content: String) throws {
        guard !isSyncing else { throw WorkspaceFilesystemError.workspaceLocked }

        let fileURL = try resolveSecureURL(relativePath: relativePath)
        var isDir: ObjCBool = false
        guard fileManager.fileExists(atPath: fileURL.path, isDirectory: &isDir), !isDir.boolValue else {
            throw WorkspaceFilesystemError.itemNotFound(path: relativePath)
        }

        guard let data = content.data(using: .utf8) else {
            throw WorkspaceFilesystemError.ioError(description: "Unable to encode Markdown text as UTF-8.")
        }

        do {
            try data.write(to: fileURL, options: .atomic)
        } catch {
            throw WorkspaceFilesystemError.ioError(description: error.localizedDescription)
        }
    }

    // MARK: - Path Normalization & Security Boundary Verification

    public func resolveSecureURL(relativePath: String) throws -> URL {
        var trimmed = relativePath.trimmingCharacters(in: .whitespacesAndNewlines)
        while trimmed.hasPrefix("/") {
            trimmed.removeFirst()
        }

        // Boundary guard 1: Check components for protected directories and traversal
        let components = trimmed.components(separatedBy: "/")
        if components.contains(where: { $0 == ".syncstore" || $0.hasPrefix(".syncstore") }) {
            throw WorkspaceFilesystemError.protectedPath(path: relativePath)
        }

        if components.contains("..") {
            throw WorkspaceFilesystemError.pathTraversal(path: relativePath)
        }

        let targetURL = trimmed.isEmpty ? baseURL : baseURL.appendingPathComponent(trimmed)
        let canonicalBase = baseURL.standardizedFileURL.path
        let canonicalTarget = targetURL.standardizedFileURL.path

        // Boundary guard 2: Canonical prefix confinement check
        guard canonicalTarget == canonicalBase || canonicalTarget.hasPrefix(canonicalBase + "/") else {
            throw WorkspaceFilesystemError.pathTraversal(path: relativePath)
        }

        return targetURL
    }

    private func makeRelativeDisplayPath(for url: URL) -> String {
        let basePath = baseURL.standardizedFileURL.path
        let itemPath = url.standardizedFileURL.path

        if itemPath == basePath {
            return "/"
        }
        if itemPath.hasPrefix(basePath) {
            let relative = String(itemPath.dropFirst(basePath.count))
            return relative.hasPrefix("/") ? relative : "/\(relative)"
        }
        return "/\(url.lastPathComponent)"
    }

    private func validateItemName(_ name: String) throws -> String {
        #if canImport(SharedLogic)
        let kmpResult = FileItemValidator.shared.validateItemName(name: name)
        if let invalid = kmpResult as? PathValidationResult.Invalid {
            throw WorkspaceFilesystemError.invalidName(reason: invalid.message)
        }
        #endif

        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw WorkspaceFilesystemError.invalidName(reason: "Item name cannot be empty")
        }
        if trimmed.contains("/") || trimmed.contains("\\") {
            throw WorkspaceFilesystemError.invalidName(reason: "Item name cannot contain path separators")
        }
        if trimmed == ".syncstore" || trimmed.hasPrefix(".syncstore") {
            throw WorkspaceFilesystemError.protectedPath(path: trimmed)
        }
        if trimmed.hasPrefix(".") {
            throw WorkspaceFilesystemError.invalidName(reason: "Hidden items starting with '.' are not allowed")
        }
        let illegalCharacters = CharacterSet(charactersIn: ":*?\"<>|\0")
        if trimmed.rangeOfCharacter(from: illegalCharacters) != nil {
            throw WorkspaceFilesystemError.invalidName(reason: "Item name contains forbidden characters")
        }
        return trimmed
    }

    // MARK: - Markdown Frontmatter & Inline Tag Extractor

    public static func extractTags(from content: String) -> [String] {
        var tagsSet = Set<String>()
        tagsSet.insert("#all")

        // 1. YAML frontmatter extraction (--- delimited)
        if content.hasPrefix("---") {
            let lines = content.components(separatedBy: .newlines)
            var inFrontmatter = false
            var frontmatterEnd = -1

            for (idx, line) in lines.enumerated() {
                if line.trimmingCharacters(in: .whitespaces) == "---" {
                    if !inFrontmatter && idx == 0 {
                        inFrontmatter = true
                    } else if inFrontmatter {
                        frontmatterEnd = idx
                        break
                    }
                }
            }

            if inFrontmatter && frontmatterEnd > 0 {
                for i in 1..<frontmatterEnd {
                    let line = lines[i].trimmingCharacters(in: .whitespaces)
                    if line.starts(with: "tags:") {
                        let rest = line.dropFirst(5).trimmingCharacters(in: .whitespaces)
                        if rest.hasPrefix("[") && rest.hasSuffix("]") {
                            let inner = rest.dropFirst().dropLast()
                            let parts = inner.components(separatedBy: ",")
                            for part in parts {
                                let clean = part.trimmingCharacters(in: CharacterSet(charactersIn: " \"'"))
                                if !clean.isEmpty {
                                    tagsSet.insert(clean.hasPrefix("#") ? clean.lowercased() : "#\(clean.lowercased())")
                                }
                            }
                        }
                    } else if line.hasPrefix("- ") {
                        let clean = line.dropFirst(2).trimmingCharacters(in: CharacterSet(charactersIn: " \"'"))
                        if !clean.isEmpty && !clean.contains(":") {
                            tagsSet.insert(clean.hasPrefix("#") ? clean.lowercased() : "#\(clean.lowercased())")
                        }
                    }
                }
            }
        }

        // 2. Inline #tag token extraction
        let pattern = #"(?<=\s|^)#[a-zA-Z0-9_\-]+(?=\s|$|[.,;:!?])"#
        if let regex = try? NSRegularExpression(pattern: pattern) {
            let nsString = content as NSString
            let matches = regex.matches(in: content, range: NSRange(location: 0, length: nsString.length))
            for match in matches {
                let tag = nsString.substring(with: match.range).trimmingCharacters(in: .whitespaces)
                if tag.count > 1 {
                    tagsSet.insert(tag.lowercased())
                }
            }
        }

        return Array(tagsSet).sorted()
    }

    // MARK: - Offline Disconnect Pending Storage (.syncstore/pending.json)

    @discardableResult
    public func savePendingRevision(revision: String, resolutions: [String: String]) throws -> URL {
        let syncStoreURL = baseURL.appendingPathComponent(".syncstore", isDirectory: true)
        if !fileManager.fileExists(atPath: syncStoreURL.path) {
            try fileManager.createDirectory(at: syncStoreURL, withIntermediateDirectories: true)
        }
        let pendingFileURL = syncStoreURL.appendingPathComponent("pending.json")
        let payload: [String: Any] = [
            "revisionId": revision,
            "status": "resolvedLocally",
            "timestamp": Date().timeIntervalSince1970,
            "resolutions": resolutions
        ]
        let data = try JSONSerialization.data(withJSONObject: payload, options: [.prettyPrinted])
        try data.write(to: pendingFileURL, options: .atomic)
        return pendingFileURL
    }

    public func readPendingRevision() -> [String: Any]? {
        let pendingFileURL = baseURL.appendingPathComponent(".syncstore/pending.json")
        guard fileManager.fileExists(atPath: pendingFileURL.path),
              let data = try? Data(contentsOf: pendingFileURL),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }
        return json
    }

    public func clearPendingRevision() {
        let pendingFileURL = baseURL.appendingPathComponent(".syncstore/pending.json")
        if fileManager.fileExists(atPath: pendingFileURL.path) {
            try? fileManager.removeItem(at: pendingFileURL)
        }
    }
}

