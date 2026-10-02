import SwiftUI

public struct ConflictFileRow: View {
    public let file: ConflictingFileItem
    public let isSelected: Bool
    public let onSelect: () -> Void
    public let onResolveLocal: () -> Void
    public let onResolvePeer: () -> Void
    public let onInspectDiff: () -> Void
    public let onChange: () -> Void
    
    public init(
        file: ConflictingFileItem,
        isSelected: Bool,
        onSelect: @escaping () -> Void,
        onResolveLocal: @escaping () -> Void,
        onResolvePeer: @escaping () -> Void,
        onInspectDiff: @escaping () -> Void,
        onChange: @escaping () -> Void
    ) {
        self.file = file
        self.isSelected = isSelected
        self.onSelect = onSelect
        self.onResolveLocal = onResolveLocal
        self.onResolvePeer = onResolvePeer
        self.onInspectDiff = onInspectDiff
        self.onChange = onChange
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Action Required Tag
            if !file.isResolved {
                HStack {
                    Spacer()
                    Text("ACTION REQUIRED")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(AgedManuscriptTheme.Colors.parchment)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(AgedManuscriptTheme.Colors.inkDark)
                        .cornerRadius(4)
                }
            }
            
            // Header: Path & Badge
            HStack(alignment: .center) {
                HStack(spacing: 6) {
                    Image(systemName: file.isResolved ? "checkmark.circle.fill" : "doc.text")
                        .foregroundColor(file.isResolved ? AgedManuscriptTheme.Colors.statusGreen : AgedManuscriptTheme.Colors.inkDark)
                    
                    Text(file.path)
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundColor(AgedManuscriptTheme.Colors.inkDark)
                        .lineLimit(1)
                }
                
                Spacer()
                
                ConflictKindBadge(kind: file.kind)
            }
            
            // Details Subtext
            Text("Edited on both \(file.localDeviceName) (\(file.localTimestamp)) and \(file.peerDeviceName) (\(file.peerTimestamp))")
                .font(.system(size: 12))
                .foregroundColor(AgedManuscriptTheme.Colors.inkSecondary)
                .lineLimit(2)
            
            if file.isResolved {
                // Resolved state box
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Resolved: \(file.resolvedStrategy?.label ?? "")")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(AgedManuscriptTheme.Colors.statusGreen)
                        Text("Selection confirmed")
                            .font(.system(size: 11))
                            .foregroundColor(AgedManuscriptTheme.Colors.inkSecondary)
                    }
                    
                    Spacer()
                    
                    Button("Change", action: onChange)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(AgedManuscriptTheme.Colors.inkDark)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(AgedManuscriptTheme.Colors.parchment)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(AgedManuscriptTheme.Colors.parchmentBorder, lineWidth: 1)
                )
                .cornerRadius(8)
            } else {
                // Unresolved choices
                VStack(spacing: 8) {
                    // Option A: Keep This Phone
                    Button(action: onResolveLocal) {
                        HStack {
                            Circle()
                                .stroke(AgedManuscriptTheme.Colors.inkSecondary, lineWidth: 1.5)
                                .frame(width: 14, height: 14)
                            Text("Keep This Phone's Version (\(file.localDeviceName))")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(AgedManuscriptTheme.Colors.inkDark)
                            Spacer()
                            Image(systemName: "iphone")
                                .foregroundColor(AgedManuscriptTheme.Colors.inkSecondary)
                        }
                        .padding(10)
                        .background(AgedManuscriptTheme.Colors.parchment)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(AgedManuscriptTheme.Colors.parchmentBorder, lineWidth: 1)
                        )
                        .cornerRadius(8)
                    }
                    
                    // Option B: Keep Peer Version
                    Button(action: onResolvePeer) {
                        HStack {
                            Circle()
                                .stroke(AgedManuscriptTheme.Colors.inkSecondary, lineWidth: 1.5)
                                .frame(width: 14, height: 14)
                            Text("Keep Peer Version (\(file.peerDeviceName))")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(AgedManuscriptTheme.Colors.inkDark)
                            Spacer()
                            Image(systemName: "laptopcomputer")
                                .foregroundColor(AgedManuscriptTheme.Colors.inkSecondary)
                        }
                        .padding(10)
                        .background(AgedManuscriptTheme.Colors.parchment)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(AgedManuscriptTheme.Colors.parchmentBorder, lineWidth: 1)
                        )
                        .cornerRadius(8)
                    }
                    
                    // Option C: Review Line-by-Line Diff
                    Button(action: onInspectDiff) {
                        HStack {
                            Image(systemName: "arrow.triangle.branch")
                                .foregroundColor(AgedManuscriptTheme.Colors.inkDark)
                            Text("Review Line-by-Line Diff (Hunk Picker)...")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(AgedManuscriptTheme.Colors.inkDark)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(AgedManuscriptTheme.Colors.inkDark)
                        }
                        .padding(10)
                        .background(AgedManuscriptTheme.Colors.parchmentField)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(AgedManuscriptTheme.Colors.inkDark, lineWidth: 1)
                        )
                        .cornerRadius(8)
                    }
                }
            }
        }
        .padding(14)
        .background(AgedManuscriptTheme.Colors.parchmentCard)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? AgedManuscriptTheme.Colors.inkSecondary : AgedManuscriptTheme.Colors.parchmentBorder, lineWidth: isSelected ? 2 : 1)
        )
        .cornerRadius(12)
        .onTapGesture {
            onSelect()
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        ConflictFileRow(
            file: ConflictingFileItem(
                path: "Research/q3-strategy.md",
                kind: .content,
                resolvedStrategy: nil
            ),
            isSelected: true,
            onSelect: {},
            onResolveLocal: {},
            onResolvePeer: {},
            onInspectDiff: {},
            onChange: {}
        )
        
        ConflictFileRow(
            file: ConflictingFileItem(
                path: "Projects/todo.md",
                kind: .content,
                resolvedStrategy: .local
            ),
            isSelected: false,
            onSelect: {},
            onResolveLocal: {},
            onResolvePeer: {},
            onInspectDiff: {},
            onChange: {}
        )
    }
    .padding()
    .background(AgedManuscriptTheme.Colors.parchment)
}
