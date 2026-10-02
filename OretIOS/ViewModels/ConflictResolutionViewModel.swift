import Foundation
import Observation

@Observable
public final class ConflictResolutionViewModel {
    public var conflicts: [ConflictingFileItem]
    public var activeFileId: String?
    public var activeHunkId: String?
    public var isPeerConnected: Bool
    public var isResolving: Bool
    public var localDeviceName: String
    public var peerDeviceName: String
    public var summary: SyncSummaryReport?
    public var pendingRevisionId: String?

    public var totalCount: Int {
        conflicts.count
    }

    public var resolvedCount: Int {
        conflicts.filter { $0.isResolved }.count
    }

    public var allResolved: Bool {
        !conflicts.isEmpty && conflicts.allSatisfy { $0.isResolved }
    }

    public var activeFile: ConflictingFileItem? {
        conflicts.first { $0.id == activeFileId } ?? conflicts.first
    }

    private let fileService: WorkspaceFilesystemProtocol?

    public init(
        conflicts: [ConflictingFileItem] = ConflictResolutionViewModel.defaultSampleConflicts(),
        fileService: WorkspaceFilesystemProtocol? = nil,
        isPeerConnected: Bool = true,
        localDeviceName: String = "iPhone 15 Pro",
        peerDeviceName: String = "MacBook Pro"
    ) {
        self.conflicts = conflicts
        self.fileService = fileService
        self.activeFileId = conflicts.first?.id
        self.activeHunkId = conflicts.first?.hunks.first?.id
        self.isPeerConnected = isPeerConnected
        self.isResolving = false
        self.localDeviceName = localDeviceName
        self.peerDeviceName = peerDeviceName
    }

    public func selectFile(id: String) {
        activeFileId = id
        if let file = conflicts.first(where: { $0.id == id }) {
            activeHunkId = file.hunks.first?.id
        }
    }

    public func resolveFile(id: String, strategy: ResolutionStrategy) {
        if let idx = conflicts.firstIndex(where: { $0.id == id }) {
            conflicts[idx].resolvedStrategy = strategy
            for hIdx in conflicts[idx].hunks.indices {
                conflicts[idx].hunks[hIdx].resolvedChoice = strategy.rawValue
            }
        }
    }

    public func resolveHunk(fileId: String, hunkId: String, choice: String) {
        guard let fIdx = conflicts.firstIndex(where: { $0.id == fileId }) else { return }
        guard let hIdx = conflicts[fIdx].hunks.firstIndex(where: { $0.id == hunkId }) else { return }
        
        conflicts[fIdx].hunks[hIdx].resolvedChoice = choice
        let allDone = conflicts[fIdx].hunks.allSatisfy { $0.resolvedChoice != nil }
        if allDone {
            conflicts[fIdx].resolvedStrategy = .hunkMerge
        }
    }

    public func applyResolutions() -> SyncSummaryReport? {
        guard allResolved else { return nil }
        isResolving = true
        fileService?.clearPendingRevision()
        let result = SyncSummaryReport(
            autoMergedCount: 4,
            resolvedConflictsCount: conflicts.count,
            addedCount: 1,
            unchangedCount: 18,
            revisionId: "rev-9c1d4e2a",
            peerDeviceName: peerDeviceName,
            completedTimestamp: "Today at 16:32",
            resolvedFiles: conflicts.map { $0.path }
        )
        self.summary = result
        isResolving = false
        return result
    }

    public func saveOfflineAndDeliver() -> String? {
        guard allResolved else { return nil }
        let rev = "rev-3f8b9c1d"
        self.pendingRevisionId = rev
        let resolutions = conflicts.reduce(into: [String: String]()) { map, file in
            map[file.id] = file.resolvedStrategy?.rawValue ?? "local"
        }
        _ = try? fileService?.savePendingRevision(revision: rev, resolutions: resolutions)
        return rev
    }

    public static func defaultSampleConflicts() -> [ConflictingFileItem] {
        return [
            ConflictingFileItem(
                id: "conf-1",
                path: "Research/q3-strategy.md",
                kind: .content,
                hunksCount: 2,
                localTimestamp: "14:10",
                peerTimestamp: "14:15",
                localDeviceName: "iPhone 15 Pro",
                peerDeviceName: "MacBook Pro",
                hunks: [
                    ConflictHunk(
                        id: "hunk-1",
                        lineRange: "Lines 14–22",
                        title: "Strategic Pillars & Timeline",
                        localLines: [
                            ConflictHunkLine(text: "## Strategic Goals for Q3"),
                            ConflictHunkLine(text: "Focus purely on offline sync."),
                            ConflictHunkLine(text: "Target launch date: Sept 15.", isChange: true, isDeletion: true),
                            ConflictHunkLine(text: "Ledger stability verified.")
                        ],
                        peerLines: [
                            ConflictHunkLine(text: "## Strategic Goals for Q3"),
                            ConflictHunkLine(text: "Focus purely on offline sync."),
                            ConflictHunkLine(text: "Target launch date: Oct 01 (extended beta).", isChange: true, isAddition: true),
                            ConflictHunkLine(text: "Ledger stability verified.")
                        ]
                    ),
                    ConflictHunk(
                        id: "hunk-2",
                        lineRange: "Lines 45–52",
                        title: "Budget Allocations",
                        localLines: [
                            ConflictHunkLine(text: "Infrastructure allocation: $1,200", isChange: true, isDeletion: true),
                            ConflictHunkLine(text: "Contingency reserve: $300")
                        ],
                        peerLines: [
                            ConflictHunkLine(text: "Infrastructure allocation: $1,500", isChange: true, isAddition: true),
                            ConflictHunkLine(text: "Contingency reserve: $300")
                        ]
                    )
                ],
                resolvedStrategy: nil
            ),
            ConflictingFileItem(
                id: "conf-2",
                path: "Projects/todo.md",
                kind: .content,
                hunksCount: 1,
                localTimestamp: "13:40",
                peerTimestamp: "13:45",
                localDeviceName: "iPhone 15 Pro",
                peerDeviceName: "MacBook Pro",
                hunks: [
                    ConflictHunk(
                        id: "hunk-3",
                        lineRange: "Lines 1–8",
                        title: "Task List",
                        localLines: [ConflictHunkLine(text: "- [x] Complete MVP")],
                        peerLines: [ConflictHunkLine(text: "- [ ] Complete MVP draft")]
                    )
                ],
                resolvedStrategy: .local
            )
        ]
    }
}
