//
//  FileExplorerScreen.swift
//  OretIOS
//
//  Mobile File Explorer Screen (Aged Manuscript theme)
//  Conforms to Stitch Specifications fa5a2a111bf44039bffd6418e37b3531
//

import SwiftUI

public struct FileExplorerScreen: View {
    @State private var viewModel: FileExplorerViewModel
    public var onSettings: (() -> Void)?
    public var onFileSelected: ((FileItem) -> Void)?

    public init(
        workspaceName: String = "personal-notes",
        initialItems: [FileItem] = FileItem.sampleHierarchy,
        onSettings: (() -> Void)? = nil,
        onFileSelected: ((FileItem) -> Void)? = nil
    ) {
        self._viewModel = State(
            initialValue: FileExplorerViewModel(
                workspaceName: workspaceName,
                initialItems: initialItems
            )
        )
        self.onSettings = onSettings
        self.onFileSelected = onFileSelected
    }

    public var body: some View {
        ZStack {
            // Screen Background
            AgedManuscriptTheme.Colors.parchment
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header Top Bar
                headerTopBar

                // Middle Tree Content Area
                FileTreeView(
                    items: viewModel.displayedItems,
                    selectedItemId: viewModel.selectedItemId,
                    inlineCreationTarget: viewModel.inlineCreationTarget,
                    inlineCreationName: $viewModel.inlineCreationName,
                    inlineCreationIsFolder: viewModel.inlineCreationIsFolder,
                    onToggleExpand: { item in
                        viewModel.toggleExpand(item: item)
                    },
                    onSelect: { item in
                        viewModel.selectedItemId = item.id
                        onFileSelected?(item)
                    },
                    onOptions: { item in
                        viewModel.activeOptionsItem = item
                    },
                    onCommitInlineCreation: {
                        viewModel.commitInlineCreation()
                    },
                    onCancelInlineCreation: {
                        viewModel.cancelInlineCreation()
                    }
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                // Bottom Search & Action Dock
                BottomSearchDock(
                    tags: viewModel.availableTags,
                    selectedTag: viewModel.selectedTag,
                    searchQuery: $viewModel.searchQuery,
                    onSelectTag: { tag in
                        viewModel.selectTag(tag)
                    },
                    onNewFile: {
                        viewModel.createModalInitialIsFolder = false
                        viewModel.createModalInitialFolder = "/"
                        viewModel.showCreateModal = true
                    },
                    onNewFolder: {
                        viewModel.createModalInitialIsFolder = true
                        viewModel.createModalInitialFolder = "/"
                        viewModel.showCreateModal = true
                    }
                )
            }

            // Modal: File Options Bottom Sheet
            if let activeItem = viewModel.activeOptionsItem {
                FileOptionsSheet(
                    item: activeItem,
                    isPresented: Binding(
                        get: { viewModel.activeOptionsItem != nil },
                        set: { if !$0 { viewModel.activeOptionsItem = nil } }
                    ),
                    onRename: {
                        viewModel.activeRenameItem = activeItem
                    },
                    onDuplicate: {
                        viewModel.duplicateItem(item: activeItem)
                    },
                    onMove: {
                        viewModel.activeMoveItem = activeItem
                    },
                    onDelete: {
                        viewModel.activeDeleteItem = activeItem
                    }
                )
                .transition(.opacity.combined(with: .move(edge: .bottom)))
                .zIndex(20)
            }

            // Modal: Create New Item
            if viewModel.showCreateModal {
                CreateItemModal(
                    isPresented: $viewModel.showCreateModal,
                    availableFolders: viewModel.allFolderPaths,
                    initialFolder: viewModel.createModalInitialFolder,
                    initialIsFolder: viewModel.createModalInitialIsFolder,
                    onCreate: { name, isFolder, destination in
                        viewModel.createItem(
                            name: name,
                            isFolder: isFolder,
                            destinationFolder: destination
                        )
                    }
                )
                .transition(.opacity)
                .zIndex(30)
            }

            // Modal: Rename Item
            if let renameItem = viewModel.activeRenameItem {
                RenameModal(
                    item: renameItem,
                    isPresented: Binding(
                        get: { viewModel.activeRenameItem != nil },
                        set: { if !$0 { viewModel.activeRenameItem = nil } }
                    ),
                    onRename: { newName in
                        viewModel.renameItem(item: renameItem, newName: newName)
                    }
                )
                .transition(.opacity)
                .zIndex(30)
            }

            // Modal: Delete Item Confirmation
            if let deleteItem = viewModel.activeDeleteItem {
                DeleteConfirmationModal(
                    item: deleteItem,
                    isPresented: Binding(
                        get: { viewModel.activeDeleteItem != nil },
                        set: { if !$0 { viewModel.activeDeleteItem = nil } }
                    ),
                    onConfirmDelete: {
                        viewModel.deleteItem(item: deleteItem)
                    }
                )
                .transition(.opacity)
                .zIndex(30)
            }

            // Modal: Move Path Chooser
            if let moveItem = viewModel.activeMoveItem {
                MovePathModal(
                    item: moveItem,
                    availableFolders: viewModel.allFolderPaths,
                    isPresented: Binding(
                        get: { viewModel.activeMoveItem != nil },
                        set: { if !$0 { viewModel.activeMoveItem = nil } }
                    ),
                    onMove: { destination in
                        viewModel.moveItem(item: moveItem, destinationFolder: destination)
                    }
                )
                .transition(.opacity)
                .zIndex(30)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: viewModel.activeOptionsItem != nil)
        .animation(.easeInOut(duration: 0.2), value: viewModel.showCreateModal)
        .animation(.easeInOut(duration: 0.2), value: viewModel.activeRenameItem != nil)
        .animation(.easeInOut(duration: 0.2), value: viewModel.activeDeleteItem != nil)
        .animation(.easeInOut(duration: 0.2), value: viewModel.activeMoveItem != nil)
    }

    // MARK: - Header Top Bar (Stitch fa5a2a111bf44039bffd6418e37b3531)
    private var headerTopBar: some View {
        VStack(spacing: 8) {
            // Row 1: Workspace Title & Settings
            HStack(spacing: 8) {
                Text("Workspace: \(viewModel.workspaceName)")
                    .font(AgedManuscriptTheme.Fonts.serifTitle(size: 20, weight: .semibold))
                    .foregroundColor(AgedManuscriptTheme.Colors.inkPrimary)
                    .lineLimit(1)
                    .layoutPriority(1)

                Spacer()

                Button(action: {
                    onSettings?()
                }) {
                    Image(systemName: "gearshape")
                        .font(.system(size: 18, weight: .regular))
                        .foregroundColor(AgedManuscriptTheme.Colors.inkSecondary)
                        .frame(width: 32, height: 32)
                        .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())
                .accessibilityLabel(Text("Settings"))
            }

            // Row 2: Status sync button, stats count, and expand/collapse actions
            HStack(spacing: 8) {
                // Synced indicator button
                HStack(spacing: 5) {
                    Circle()
                        .fill(AgedManuscriptTheme.Colors.statusGreen)
                        .frame(width: 7, height: 7)

                    Text("Synced")
                        .font(AgedManuscriptTheme.Fonts.sansLabel(size: 12, weight: .medium))
                        .foregroundColor(AgedManuscriptTheme.Colors.inkPrimary)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(AgedManuscriptTheme.Colors.parchment)
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(AgedManuscriptTheme.Colors.parchmentBorder, lineWidth: 1)
                )

                Spacer()

                // Stats badge
                Text(viewModel.statsSummary)
                    .font(AgedManuscriptTheme.Fonts.sansLabel(size: 11, weight: .regular))
                    .foregroundColor(AgedManuscriptTheme.Colors.inkSecondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(AgedManuscriptTheme.Colors.parchmentField)
                    .clipShape(Capsule())
                    .overlay(
                        Capsule()
                            .stroke(AgedManuscriptTheme.Colors.parchmentBorder.opacity(0.6), lineWidth: 1)
                    )

                // Expand All
                Button(action: {
                    viewModel.expandAll()
                }) {
                    Image(systemName: "arrow.up.left.and.arrow.down.right")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(AgedManuscriptTheme.Colors.inkSecondary)
                        .frame(width: 26, height: 26)
                        .background(AgedManuscriptTheme.Colors.parchment)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(AgedManuscriptTheme.Colors.parchmentBorder, lineWidth: 1)
                        )
                }
                .buttonStyle(PlainButtonStyle())
                .accessibilityLabel(Text("Expand All"))

                // Collapse All
                Button(action: {
                    viewModel.collapseAll()
                }) {
                    Image(systemName: "arrow.down.right.and.arrow.up.left")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(AgedManuscriptTheme.Colors.inkSecondary)
                        .frame(width: 26, height: 26)
                        .background(AgedManuscriptTheme.Colors.parchment)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(AgedManuscriptTheme.Colors.parchmentBorder, lineWidth: 1)
                        )
                }
                .buttonStyle(PlainButtonStyle())
                .accessibilityLabel(Text("Collapse All"))
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 10)
        .background(AgedManuscriptTheme.Colors.parchmentField)
        .overlay(
            Rectangle()
                .fill(AgedManuscriptTheme.Colors.parchmentBorder)
                .frame(height: 1),
            alignment: .bottom
        )
    }
}

// MARK: - SwiftUI #Previews

#Preview("Clean Base Explorer") {
    FileExplorerScreen(
        workspaceName: "personal-notes"
    )
}

#Preview("File Options Sheet Open") {
    let vm = FileExplorerViewModel(workspaceName: "personal-notes")
    vm.activeOptionsItem = FileItem(
        name: "roadmap.md",
        path: "/Work/Q3 Planning/roadmap.md",
        isDirectory: false
    )
    return FileExplorerScreen(
        workspaceName: "personal-notes"
    )
}

#Preview("Create Item Modal Open") {
    let vm = FileExplorerViewModel(workspaceName: "personal-notes")
    vm.showCreateModal = true
    return FileExplorerScreen(
        workspaceName: "personal-notes"
    )
}

#Preview("Rename Note Modal Open") {
    let vm = FileExplorerViewModel(workspaceName: "personal-notes")
    vm.activeRenameItem = FileItem(
        name: "roadmap.md",
        path: "/Work/Q3 Planning/roadmap.md",
        isDirectory: false
    )
    return FileExplorerScreen(
        workspaceName: "personal-notes"
    )
}

#Preview("Delete Confirmation Open") {
    let vm = FileExplorerViewModel(workspaceName: "personal-notes")
    vm.activeDeleteItem = FileItem(
        name: "roadmap.md",
        path: "/Work/Q3 Planning/roadmap.md",
        isDirectory: false,
        sizeBytes: 2457
    )
    return FileExplorerScreen(
        workspaceName: "personal-notes"
    )
}

#Preview("Move Path Modal Open") {
    let vm = FileExplorerViewModel(workspaceName: "personal-notes")
    vm.activeMoveItem = FileItem(
        name: "roadmap.md",
        path: "/Work/Q3 Planning/roadmap.md",
        isDirectory: false
    )
    return FileExplorerScreen(
        workspaceName: "personal-notes"
    )
}
