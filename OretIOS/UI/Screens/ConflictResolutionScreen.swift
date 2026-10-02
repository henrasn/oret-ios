import SwiftUI

public struct ConflictResolutionScreen: View {
    @State public var viewModel: ConflictResolutionViewModel
    public var onDismiss: () -> Void
    public var onCompleteSync: (SyncSummaryReport) -> Void
    public var onSavedOffline: (String) -> Void
    
    @State private var inspectingFileId: String? = nil
    
    public init(
        viewModel: ConflictResolutionViewModel = ConflictResolutionViewModel(),
        onDismiss: @escaping () -> Void = {},
        onCompleteSync: @escaping (SyncSummaryReport) -> Void = { _ in },
        onSavedOffline: @escaping (String) -> Void = { _ in }
    ) {
        self._viewModel = State(initialValue: viewModel)
        self.onDismiss = onDismiss
        self.onCompleteSync = onCompleteSync
        self.onSavedOffline = onSavedOffline
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Top App Bar
            HStack {
                Button(action: onDismiss) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(AgedManuscriptTheme.Colors.inkDark)
                }
                
                Spacer()
                
                Text("Resolve Conflicts")
                    .font(.system(size: 18, weight: .bold, design: .serif))
                    .foregroundColor(AgedManuscriptTheme.Colors.inkDark)
                
                Spacer()
                
                // Progress Chip
                HStack(spacing: 6) {
                    Circle()
                        .fill(viewModel.allResolved ? AgedManuscriptTheme.Colors.statusGreen : AgedManuscriptTheme.Colors.inkSecondary)
                        .frame(width: 6, height: 6)
                    
                    Text("\(viewModel.resolvedCount) of \(viewModel.totalCount) resolved")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(AgedManuscriptTheme.Colors.inkSecondary)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(AgedManuscriptTheme.Colors.parchmentField)
                .overlay(
                    Capsule()
                        .stroke(AgedManuscriptTheme.Colors.parchmentBorder, lineWidth: 1)
                )
                .clipShape(Capsule())
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(AgedManuscriptTheme.Colors.parchment)
            .overlay(
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(AgedManuscriptTheme.Colors.parchmentBorder),
                alignment: .bottom
            )
            
            // Subheader Alert Banner
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 16))
                    .foregroundColor(AgedManuscriptTheme.Colors.inkSecondary)
                
                Text("**\(viewModel.totalCount) files have conflicting edits.** Choose which version to keep before completing sync.")
                    .font(.system(size: 12))
                    .foregroundColor(AgedManuscriptTheme.Colors.inkDark)
                    .lineLimit(2)
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(AgedManuscriptTheme.Colors.parchmentField)
            .overlay(
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(AgedManuscriptTheme.Colors.parchmentBorder),
                alignment: .bottom
            )
            
            // Offline Review Banner
            if !viewModel.isPeerConnected {
                OfflineNoticeBannerView(peerDeviceName: viewModel.peerDeviceName)
            }
            
            // Scrollable Content
            ScrollView {
                VStack(spacing: 14) {
                    ForEach(viewModel.conflicts) { file in
                        ConflictFileRow(
                            file: file,
                            isSelected: file.id == viewModel.activeFileId,
                            onSelect: {
                                viewModel.selectFile(id: file.id)
                            },
                            onResolveLocal: {
                                viewModel.resolveFile(id: file.id, strategy: .local)
                            },
                            onResolvePeer: {
                                viewModel.resolveFile(id: file.id, strategy: .peer)
                            },
                            onInspectDiff: {
                                inspectingFileId = file.id
                            },
                            onChange: {
                                viewModel.resolveFile(id: file.id, strategy: .local)
                            }
                        )
                        
                        // Inline Hunk Diff Inspector if active
                        if inspectingFileId == file.id {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Line-by-Line Hunk Review for \(file.path):")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(AgedManuscriptTheme.Colors.inkDark)
                                
                                ForEach(file.hunks) { hunk in
                                    HunkDiffView(
                                        hunk: hunk,
                                        localDeviceName: viewModel.localDeviceName,
                                        peerDeviceName: viewModel.peerDeviceName,
                                        onPickLocal: {
                                            viewModel.resolveHunk(fileId: file.id, hunkId: hunk.id, choice: "local")
                                        },
                                        onPickPeer: {
                                            viewModel.resolveHunk(fileId: file.id, hunkId: hunk.id, choice: "peer")
                                        },
                                        onPickBoth: {
                                            viewModel.resolveHunk(fileId: file.id, hunkId: hunk.id, choice: "both")
                                        }
                                    )
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    
                    // Archive Note
                    HStack(spacing: 10) {
                        Image(systemName: "newspaper.fill")
                            .font(.system(size: 16))
                            .foregroundColor(AgedManuscriptTheme.Colors.inkSecondary)
                        
                        Text("Snapshots auto-archived in `.resolver/backups` before conflict merge execution.")
                            .font(.system(size: 11))
                            .foregroundColor(AgedManuscriptTheme.Colors.inkSecondary)
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(AgedManuscriptTheme.Colors.parchmentField)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(AgedManuscriptTheme.Colors.parchmentBorder, lineWidth: 1)
                    )
                    .cornerRadius(8)
                }
                .padding(16)
            }
            
            // Bottom Action Bar
            VStack(spacing: 10) {
                // Guard indicator
                HStack(spacing: 6) {
                    Image(systemName: viewModel.allResolved ? "checkmark" : "lock.fill")
                        .font(.system(size: 11))
                    
                    Text(viewModel.allResolved ? "All conflicts resolved" : "\(viewModel.totalCount - viewModel.resolvedCount) unresolved file(s) remaining")
                        .font(.system(size: 11, weight: .medium))
                }
                .foregroundColor(AgedManuscriptTheme.Colors.inkSecondary)
                
                // CTA Button
                Button(action: {
                    if viewModel.isPeerConnected {
                        if let summary = viewModel.applyResolutions() {
                            onCompleteSync(summary)
                        }
                    } else {
                        if let rev = viewModel.saveOfflineAndDeliver() {
                            onSavedOffline(rev)
                        }
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 15))
                        Text(viewModel.isPeerConnected ? "Apply Resolutions & Complete Sync" : "Save Locally & Deliver via QR")
                            .font(.system(size: 14, weight: .bold))
                    }
                    .foregroundColor(viewModel.allResolved ? .white : AgedManuscriptTheme.Colors.inkSecondary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(viewModel.allResolved ? AgedManuscriptTheme.Colors.inkDark : AgedManuscriptTheme.Colors.parchmentField)
                    .cornerRadius(8)
                }
                .disabled(!viewModel.allResolved)
            }
            .padding(16)
            .background(AgedManuscriptTheme.Colors.parchment)
            .overlay(
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(AgedManuscriptTheme.Colors.parchmentBorder),
                alignment: .top
            )
        }
        .background(AgedManuscriptTheme.Colors.parchment)
    }
}

#Preview {
    ConflictResolutionScreen()
}
