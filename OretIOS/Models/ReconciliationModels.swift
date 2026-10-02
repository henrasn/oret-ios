import Foundation

public enum ConflictKind: String, Codable, CaseIterable {
    case content = "Content Conflict"
    case move = "Path Divergence"
    case deleteVsEdit = "Delete vs Edit"
    
    public var label: String { rawValue }
}

public enum ResolutionStrategy: String, Codable, CaseIterable {
    case local = "Keep This Phone"
    case peer = "Keep Peer Version"
    case hunkMerge = "Hunk Merge"
    case manual = "Custom Edit"
    
    public var label: String { rawValue }
}

public struct ConflictHunkLine: Identifiable, Codable, Equatable {
    public let id: String
    public let text: String
    public let isChange: Bool
    public let isAddition: Bool
    public let isDeletion: Bool
    
    public init(
        id: String = UUID().uuidString,
        text: String,
        isChange: Bool = false,
        isAddition: Bool = false,
        isDeletion: Bool = false
    ) {
        self.id = id
        self.text = text
        self.isChange = isChange
        self.isAddition = isAddition
        self.isDeletion = isDeletion
    }
}

public struct ConflictHunk: Identifiable, Codable, Equatable {
    public let id: String
    public let lineRange: String
    public let title: String
    public var localLines: [ConflictHunkLine]
    public var peerLines: [ConflictHunkLine]
    public var resolvedChoice: String?
    
    public init(
        id: String = UUID().uuidString,
        lineRange: String,
        title: String,
        localLines: [ConflictHunkLine],
        peerLines: [ConflictHunkLine],
        resolvedChoice: String? = nil
    ) {
        self.id = id
        self.lineRange = lineRange
        self.title = title
        self.localLines = localLines
        self.peerLines = peerLines
        self.resolvedChoice = resolvedChoice
    }
}

public struct ConflictingFileItem: Identifiable, Codable, Equatable {
    public let id: String
    public let path: String
    public let kind: ConflictKind
    public let hunksCount: Int
    public let localTimestamp: String
    public let peerTimestamp: String
    public let localDeviceName: String
    public let peerDeviceName: String
    public var hunks: [ConflictHunk]
    public var resolvedStrategy: ResolutionStrategy?
    
    public var isResolved: Bool {
        resolvedStrategy != nil
    }
    
    public init(
        id: String = UUID().uuidString,
        path: String,
        kind: ConflictKind = .content,
        hunksCount: Int = 1,
        localTimestamp: String = "14:10",
        peerTimestamp: String = "14:15",
        localDeviceName: String = "iPhone 15 Pro",
        peerDeviceName: String = "MacBook Pro",
        hunks: [ConflictHunk] = [],
        resolvedStrategy: ResolutionStrategy? = nil
    ) {
        self.id = id
        self.path = path
        self.kind = kind
        self.hunksCount = hunksCount
        self.localTimestamp = localTimestamp
        self.peerTimestamp = peerTimestamp
        self.localDeviceName = localDeviceName
        self.peerDeviceName = peerDeviceName
        self.hunks = hunks
        self.resolvedStrategy = resolvedStrategy
    }
}

public struct SyncSummaryReport: Identifiable, Codable, Equatable {
    public let id: String
    public let autoMergedCount: Int
    public let resolvedConflictsCount: Int
    public let addedCount: Int
    public let unchangedCount: Int
    public let revisionId: String
    public let peerDeviceName: String
    public let completedTimestamp: String
    public let autoMergedFiles: [String]
    public let resolvedFiles: [String]
    
    public init(
        id: String = UUID().uuidString,
        autoMergedCount: Int = 4,
        resolvedConflictsCount: Int = 2,
        addedCount: Int = 1,
        unchangedCount: Int = 18,
        revisionId: String = "rev-3f8b9c1d",
        peerDeviceName: String = "MacBook Pro",
        completedTimestamp: String = "Today at 16:32",
        autoMergedFiles: [String] = ["Projects/2026-goals.md", "Journal/october.md", "Ideas/draft.md", "README.md"],
        resolvedFiles: [String] = ["Research/q3-strategy.md", "Projects/todo.md"]
    ) {
        self.id = id
        self.autoMergedCount = autoMergedCount
        self.resolvedConflictsCount = resolvedConflictsCount
        self.addedCount = addedCount
        self.unchangedCount = unchangedCount
        self.revisionId = revisionId
        self.peerDeviceName = peerDeviceName
        self.completedTimestamp = completedTimestamp
        self.autoMergedFiles = autoMergedFiles
        self.resolvedFiles = resolvedFiles
    }
}
