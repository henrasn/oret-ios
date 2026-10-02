//
//  FileItem.swift
//  OretIOS
//
//  File & Directory Tree Data Model for Oret Mobile File Explorer
//

import Foundation

public struct FileItem: Identifiable, Equatable, Hashable {
    public let id: String
    public var name: String
    public var path: String
    public var isDirectory: Bool
    public var sizeBytes: Int64
    public var modifiedAt: Date
    public var tags: [String]
    public var isExpanded: Bool
    public var children: [FileItem]

    public init(
        id: String = UUID().uuidString,
        name: String,
        path: String,
        isDirectory: Bool = false,
        sizeBytes: Int64 = 0,
        modifiedAt: Date = Date(),
        tags: [String] = ["#all"],
        isExpanded: Bool = false,
        children: [FileItem] = []
    ) {
        self.id = id
        self.name = name
        self.path = path
        self.isDirectory = isDirectory
        self.sizeBytes = sizeBytes
        self.modifiedAt = modifiedAt
        self.tags = tags
        self.isExpanded = isExpanded
        self.children = children
    }

    #if canImport(SharedLogic)
    public init(kmpModel: FileItemModel) {
        self.init(
            id: kmpModel.id,
            name: kmpModel.name,
            path: kmpModel.path,
            isDirectory: kmpModel.isDirectory,
            sizeBytes: Int64(kmpModel.sizeBytes),
            modifiedAt: Date(),
            tags: kmpModel.tags,
            isExpanded: kmpModel.isDirectory,
            children: kmpModel.children.map { FileItem(kmpModel: $0) }
        )
    }

    public func toKmpModel() -> FileItemModel {
        FileItemModel(
            id: id,
            name: name,
            path: path,
            isDirectory: isDirectory,
            sizeBytes: sizeBytes,
            tags: tags,
            children: children.map { $0.toKmpModel() }
        )
    }
    #endif

    // MARK: - Computed Properties

    public var fileExtension: String {
        guard !isDirectory else { return "" }
        return (name as NSString).pathExtension.lowercased()
    }

    public var nameWithoutExtension: String {
        guard !isDirectory else { return name }
        return (name as NSString).deletingPathExtension
    }

    public var parentPath: String {
        let trimmed = path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        let components = trimmed.components(separatedBy: "/")
        if components.count <= 1 {
            return "/"
        }
        return "/" + components.dropLast().joined(separator: "/")
    }

    public var formattedSize: String {
        guard !isDirectory else { return "" }
        if sizeBytes < 1024 {
            return "\(sizeBytes) B"
        } else if sizeBytes < 1024 * 1024 {
            let kb = Double(sizeBytes) / 1024.0
            return String(format: "%.1f KB", kb)
        } else {
            let mb = Double(sizeBytes) / (1024.0 * 1024.0)
            return String(format: "%.1f MB", mb)
        }
    }

    public var formattedDate: String {
        let calendar = Calendar.current
        if calendar.isDateInToday(modifiedAt) {
            return "Today"
        } else if calendar.isDateInYesterday(modifiedAt) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"
            return formatter.string(from: modifiedAt)
        }
    }

    public var sfSymbolName: String {
        if isDirectory {
            return isExpanded ? "folder.fill" : "folder"
        } else if fileExtension == "md" {
            return "doc.text"
        } else {
            return "doc"
        }
    }

    // MARK: - Tree Statistics Helpers

    public var totalFoldersCount: Int {
        var count = isDirectory ? 1 : 0
        for child in children {
            count += child.totalFoldersCount
        }
        return count
    }

    public var totalFilesCount: Int {
        var count = isDirectory ? 0 : 1
        for child in children {
            count += child.totalFilesCount
        }
        return count
    }

    // MARK: - Canonical Sample Data matching Stitch Mobile Screens

    public static var sampleHierarchy: [FileItem] {
        let calendar = Calendar.current
        let now = Date()
        let oneHourAgo = calendar.date(byAdding: .hour, value: -1, to: now) ?? now
        let yesterday = calendar.date(byAdding: .day, value: -1, to: now) ?? now
        let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: now) ?? now

        return [
            FileItem(
                id: "folder_work",
                name: "Work",
                path: "/Work",
                isDirectory: true,
                isExpanded: true,
                children: [
                    FileItem(
                        id: "folder_q3_planning",
                        name: "Q3 Planning",
                        path: "/Work/Q3 Planning",
                        isDirectory: true,
                        isExpanded: true,
                        children: [
                            FileItem(
                                id: "note_roadmap",
                                name: "roadmap.md",
                                path: "/Work/Q3 Planning/roadmap.md",
                                isDirectory: false,
                                sizeBytes: 2457,
                                modifiedAt: twoDaysAgo,
                                tags: ["#all", "#project"]
                            ),
                            FileItem(
                                id: "note_budget",
                                name: "budget.md",
                                path: "/Work/Q3 Planning/budget.md",
                                isDirectory: false,
                                sizeBytes: 18432,
                                modifiedAt: twoDaysAgo,
                                tags: ["#all", "#project"]
                            )
                        ]
                    ),
                    FileItem(
                        id: "note_team_meeting",
                        name: "team-meeting.md",
                        path: "/Work/team-meeting.md",
                        isDirectory: false,
                        sizeBytes: 4096,
                        modifiedAt: yesterday,
                        tags: ["#all", "#meeting"]
                    )
                ]
            ),
            FileItem(
                id: "folder_personal",
                name: "Personal",
                path: "/Personal",
                isDirectory: true,
                isExpanded: false,
                children: [
                    FileItem(
                        id: "note_journal",
                        name: "journal.md",
                        path: "/Personal/journal.md",
                        isDirectory: false,
                        sizeBytes: 4198,
                        modifiedAt: yesterday,
                        tags: ["#all", "#ideas"]
                    )
                ]
            ),
            FileItem(
                id: "note_scratchpad",
                name: "quick-scratchpad.md",
                path: "/quick-scratchpad.md",
                isDirectory: false,
                sizeBytes: 1024,
                modifiedAt: oneHourAgo,
                tags: ["#all", "#todo"]
            ),
            FileItem(
                id: "note_reading_digest",
                name: "reading-digest.md",
                path: "/reading-digest.md",
                isDirectory: false,
                sizeBytes: 8192,
                modifiedAt: yesterday,
                tags: ["#all", "#ideas"]
            )
        ]
    }
}
