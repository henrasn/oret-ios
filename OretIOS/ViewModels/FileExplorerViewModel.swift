//
//  FileExplorerViewModel.swift
//  OretIOS
//
//  ViewModel for File Explorer State, Hierarchy, Filtering, and File Operations
//  Backed by real sandboxed FileManager persistence in Documents/notes.
//

import Foundation
import Observation

#if canImport(SharedLogic)
import SharedLogic
#endif

@Observable
public final class FileExplorerViewModel {
    public var items: [FileItem] = []
    public var workspaceName: String
    public var searchQuery: String = ""
    public var selectedTag: String = "#all"
    public var selectedItemId: String? = nil

    // Sheets & Modals state
    public var activeOptionsItem: FileItem? = nil
    public var showCreateModal: Bool = false
    public var createModalInitialFolder: String = "/"
    public var createModalInitialIsFolder: Bool = false
    public var activeRenameItem: FileItem? = nil
    public var activeDeleteItem: FileItem? = nil
    public var activeMoveItem: FileItem? = nil

    // Active Document Reading & Editing
    public var activeDocumentItem: FileItem? = nil
    public var activeDocumentContent: String = ""
    public var isSavingDocument: Bool = false

    // Inline Tree Creation state
    public var inlineCreationTarget: String? = nil
    public var inlineCreationName: String = ""
    public var inlineCreationIsFolder: Bool = false

    // Sync State
    public var isSynced: Bool = true

    // Error Notification State
    public var errorMessage: String? = nil

    // Real Sandboxed Filesystem Persistence
    public let fileService: WorkspaceFilesystemProtocol

    public init(
        workspaceName: String = "notes",
        fileService: WorkspaceFilesystemProtocol? = nil,
        initialItems: [FileItem]? = nil
    ) {
        self.workspaceName = workspaceName
        let resolvedService = fileService ?? WorkspaceFileManager(workspaceName: workspaceName)
        self.fileService = resolvedService

        if let initial = initialItems {
            self.items = initial
        } else {
            loadItems()
        }
    }

    // MARK: - Filesystem Reload & Synchronization

    public func loadItems() {
        do {
            try fileService.ensureWorkspaceExists()
            var loaded = try fileService.listTree()
            if loaded.isEmpty {
                try fileService.seedInitialContentIfEmpty()
                loaded = try fileService.listTree()
            }
            preserveExpandedStates(newItems: &loaded, oldItems: self.items)
            self.items = loaded
            self.errorMessage = nil
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    private func preserveExpandedStates(newItems: inout [FileItem], oldItems: [FileItem]) {
        var expandedPaths = Set<String>()
        func collect(list: [FileItem]) {
            for item in list {
                if item.isDirectory && item.isExpanded {
                    expandedPaths.insert(item.path)
                }
                collect(list: item.children)
            }
        }
        collect(list: oldItems)

        func apply(list: inout [FileItem]) {
            for i in 0..<list.count {
                if list[i].isDirectory {
                    if expandedPaths.contains(list[i].path) {
                        list[i].isExpanded = true
                    }
                    apply(list: &list[i].children)
                }
            }
        }
        apply(list: &newItems)
    }

    // MARK: - Computed Properties & Statistics

    public var totalFoldersCount: Int {
        items.reduce(0) { $0 + $1.totalFoldersCount }
    }

    public var totalFilesCount: Int {
        items.reduce(0) { $0 + $1.totalFilesCount }
    }

    public var statsSummary: String {
        let folders = totalFoldersCount
        let files = totalFilesCount
        return "\(folders) Folders • \(files) Files"
    }

    public var allFolderPaths: [String] {
        var paths = ["/"]
        func collect(from list: [FileItem]) {
            for item in list where item.isDirectory {
                paths.append(item.path)
                collect(from: item.children)
            }
        }
        collect(from: items)
        return Array(Set(paths)).sorted()
    }

    public var availableTags: [(tag: String, count: Int)] {
        var tagCounts: [String: Int] = [
            "#all": totalFilesCount,
            "#project": 0,
            "#meeting": 0,
            "#ideas": 0,
            "#todo": 0
        ]

        func tally(list: [FileItem]) {
            for item in list {
                if !item.isDirectory {
                    for tag in item.tags {
                        tagCounts[tag, default: 0] += 1
                    }
                } else {
                    tally(list: item.children)
                }
            }
        }
        tally(list: items)

        let standardOrder = ["#all", "#project", "#meeting", "#ideas", "#todo"]
        var results: [(tag: String, count: Int)] = []

        for tag in standardOrder {
            results.append((tag: tag, count: tagCounts[tag] ?? 0))
        }

        let otherTags = tagCounts.keys
            .filter { !standardOrder.contains($0) }
            .sorted()

        for tag in otherTags {
            results.append((tag: tag, count: tagCounts[tag] ?? 0))
        }

        return results
    }

    // Filtered items based on searchQuery & selectedTag
    public var displayedItems: [FileItem] {
        let trimmedQuery = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !trimmedQuery.isEmpty || selectedTag != "#all" else {
            return items
        }

        func filterItem(_ item: FileItem) -> FileItem? {
            if item.isDirectory {
                let filteredChildren = item.children.compactMap { filterItem($0) }
                let matchesName = trimmedQuery.isEmpty || item.name.lowercased().contains(trimmedQuery)
                if matchesName || !filteredChildren.isEmpty {
                    var copy = item
                    copy.isExpanded = true
                    copy.children = filteredChildren
                    return copy
                }
                return nil
            } else {
                let matchesQuery = trimmedQuery.isEmpty || item.name.lowercased().contains(trimmedQuery)
                let matchesTag = selectedTag == "#all" || item.tags.contains(selectedTag)
                return (matchesQuery && matchesTag) ? item : nil
            }
        }

        return items.compactMap { filterItem($0) }
    }

    // MARK: - Tree Operations

    public func toggleExpand(item: FileItem) {
        func mutate(list: inout [FileItem]) -> Bool {
            for i in 0..<list.count {
                if list[i].id == item.id {
                    list[i].isExpanded.toggle()
                    return true
                }
                if list[i].isDirectory && mutate(list: &list[i].children) {
                    return true
                }
            }
            return false
        }
        _ = mutate(list: &items)
    }

    public func expandAll() {
        func setExpand(list: inout [FileItem], value: Bool) {
            for i in 0..<list.count {
                if list[i].isDirectory {
                    list[i].isExpanded = value
                    setExpand(list: &list[i].children, value: value)
                }
            }
        }
        setExpand(list: &items, value: true)
    }

    public func collapseAll() {
        func setExpand(list: inout [FileItem], value: Bool) {
            for i in 0..<list.count {
                if list[i].isDirectory {
                    list[i].isExpanded = value
                    setExpand(list: &list[i].children, value: value)
                }
            }
        }
        setExpand(list: &items, value: false)
    }

    public func selectTag(_ tag: String) {
        if selectedTag == tag {
            selectedTag = "#all"
        } else {
            selectedTag = tag
        }
    }

    // MARK: - Real Filesystem CRUD Operations

    public func createItem(name: String, isFolder: Bool, destinationFolder: String) {
        let cleanFolder = destinationFolder.isEmpty ? "/" : destinationFolder
        do {
            if isFolder {
                _ = try fileService.createFolder(name: name, in: cleanFolder)
            } else {
                _ = try fileService.createFile(name: name, in: cleanFolder, initialContent: nil)
            }
            loadItems()
            self.errorMessage = nil
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    public func renameItem(item: FileItem, newName: String) {
        do {
            _ = try fileService.renameItem(at: item.path, to: newName)
            loadItems()
            self.errorMessage = nil
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    public func deleteItem(item: FileItem) {
        do {
            try fileService.deleteItem(at: item.path)
            if selectedItemId == item.id {
                selectedItemId = nil
            }
            if activeDocumentItem?.id == item.id {
                closeDocument()
            }
            loadItems()
            self.errorMessage = nil
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    public func duplicateItem(item: FileItem) {
        do {
            _ = try fileService.duplicateItem(at: item.path)
            loadItems()
            self.errorMessage = nil
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    public func moveItem(item: FileItem, destinationFolder: String) {
        do {
            _ = try fileService.moveItem(from: item.path, to: destinationFolder)
            loadItems()
            self.errorMessage = nil
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    // MARK: - Document Reading & Saving

    public func openDocument(item: FileItem) {
        guard !item.isDirectory else { return }
        do {
            let content = try fileService.readFile(at: item.path)
            self.activeDocumentContent = content
            self.activeDocumentItem = item
            self.errorMessage = nil
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    public func saveActiveDocument(content: String) {
        guard let item = activeDocumentItem else { return }
        isSavingDocument = true
        do {
            try fileService.saveFile(at: item.path, content: content)
            self.activeDocumentContent = content
            self.isSavingDocument = false
            loadItems()
            self.errorMessage = nil
        } catch {
            self.isSavingDocument = false
            self.errorMessage = error.localizedDescription
        }
    }

    public func closeDocument() {
        self.activeDocumentItem = nil
        self.activeDocumentContent = ""
        self.isSavingDocument = false
    }

    // MARK: - Inline Creation Helpers

    public func startInlineCreation(parentPath: String, isFolder: Bool) {
        self.inlineCreationTarget = parentPath
        self.inlineCreationIsFolder = isFolder
        self.inlineCreationName = ""
    }

    public func commitInlineCreation() {
        guard let parent = inlineCreationTarget else { return }
        let clean = inlineCreationName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !clean.isEmpty else {
            cancelInlineCreation()
            return
        }
        let finalName: String
        if inlineCreationIsFolder {
            finalName = clean
        } else {
            finalName = clean.lowercased().hasSuffix(".md") ? clean : "\(clean).md"
        }
        createItem(name: finalName, isFolder: inlineCreationIsFolder, destinationFolder: parent)
        cancelInlineCreation()
    }

    public func cancelInlineCreation() {
        self.inlineCreationTarget = nil
        self.inlineCreationName = ""
        self.inlineCreationIsFolder = false
    }
}
