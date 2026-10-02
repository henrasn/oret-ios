//
//  DirectorySetupScreen.swift
//  OretIOS
//
//  Root Directory Setup Screen embedding DirectorySetupView
//

import SwiftUI

public struct DirectorySetupScreen: View {
    @State private var viewModel: DirectorySetupViewModel
    public var onBack: (() -> Void)?
    public let onWorkspaceInitialized: (String) -> Void

    public init(
        viewModel: DirectorySetupViewModel = DirectorySetupViewModel(),
        onBack: (() -> Void)? = nil,
        onWorkspaceInitialized: @escaping (String) -> Void
    ) {
        self._viewModel = State(initialValue: viewModel)
        self.onBack = onBack
        self.onWorkspaceInitialized = onWorkspaceInitialized
    }

    public var body: some View {
        ZStack {
            AgedManuscriptTheme.Colors.parchment
                .ignoresSafeArea()

            DirectorySetupView(
                viewModel: viewModel,
                onBack: onBack,
                onConfirm: onWorkspaceInitialized
            )
        }
    }
}

#Preview {
    DirectorySetupScreen(
        onBack: {},
        onWorkspaceInitialized: { _ in }
    )
}
