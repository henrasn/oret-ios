//
//  ContentView.swift
//  OretIOS
//
//  Main Navigation Flow Coordinator
//

import SwiftUI

enum AppFlowState: Equatable, CaseIterable {
    case onboarding
    case directorySetup
    case mainWorkspace
}

struct ContentView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    @AppStorage("localPath") private var localPath: String = ""

    @State private var showSettingsSheet: Bool = false

    var body: some View {
        Group {
            switch currentFlowState {
            case .onboarding:
                OnboardingScreen {
                    hasCompletedOnboarding = true
                }

            case .directorySetup:
                DirectorySetupScreen(
                    onBack: nil,
                    onWorkspaceInitialized: { folder in
                        localPath = folder
                    }
                )

            case .mainWorkspace:
                FileExplorerScreen(
                    workspaceName: localPath.isEmpty ? WorkspaceConfiguration.defaultFolderName : localPath,
                    onSettings: {
                        showSettingsSheet = true
                    }
                )
                .sheet(isPresented: $showSettingsSheet) {
                    MainWorkspacePlaceholderView(
                        workspacePath: localPath,
                        onReset: {
                            showSettingsSheet = false
                            hasCompletedOnboarding = false
                            localPath = ""
                        }
                    )
                }
            }
        }
        .agedManuscriptBackground()
    }

    /// Rehydration State Machine matching onboarding_and_setup.md Sections 2 & 3:
    /// - Cold Start: Reads hasCompletedOnboarding & localPath from persistent storage
    /// - Gate 1: If hasCompletedOnboarding == false -> Show .onboarding
    /// - Gate 2: If hasCompletedOnboarding == true && localPath.isEmpty -> Show .directorySetup
    /// - Gate 3: If hasCompletedOnboarding == true && !localPath.isEmpty -> Show .mainWorkspace
    var currentFlowState: AppFlowState {
        if !hasCompletedOnboarding {
            return .onboarding
        } else if localPath.isEmpty {
            return .directorySetup
        } else {
            return .mainWorkspace
        }
    }
}

// MARK: - Workspace Placeholder View (Aged Manuscript Theme)
struct MainWorkspacePlaceholderView: View {
    let workspacePath: String
    let onReset: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            ZStack {
                Circle()
                    .fill(AgedManuscriptTheme.Colors.parchmentField)
                    .frame(width: 80, height: 80)
                    .overlay(
                        Circle().stroke(AgedManuscriptTheme.Colors.parchmentBorder, lineWidth: 1.5)
                    )

                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 38))
                    .foregroundColor(AgedManuscriptTheme.Colors.oliveSage)
            }

            VStack(spacing: 8) {
                Text("Workspace Initialized")
                    .font(AgedManuscriptTheme.Fonts.serifTitle(size: 26, weight: .bold))
                    .foregroundColor(AgedManuscriptTheme.Colors.inkPrimary)

                Text("Local sandboxed notes repository is ready.")
                    .font(AgedManuscriptTheme.Fonts.sansBody(size: 15))
                    .foregroundColor(AgedManuscriptTheme.Colors.inkSecondary)
            }

            HStack(spacing: 6) {
                Image(systemName: "folder")
                    .foregroundColor(AgedManuscriptTheme.Colors.inkMuted)
                Text(WorkspaceConfiguration.resolvedDisplayPath(for: workspacePath))
                    .font(AgedManuscriptTheme.Fonts.monoCode(size: 13, weight: .medium))
                    .foregroundColor(AgedManuscriptTheme.Colors.inkPrimary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(AgedManuscriptTheme.Colors.parchmentField)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(AgedManuscriptTheme.Colors.parchmentBorder, lineWidth: 1)
            )

            Spacer()

            Button(action: { showSyncHub = true }) {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.triangle.2.circlepath")
                    Text("Device Sync Hub")
                }
                .font(AgedManuscriptTheme.Fonts.sansBody(size: 14, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(AgedManuscriptTheme.Colors.inkDark)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .padding(.horizontal, 16)
            .sheet(isPresented: $showSyncHub) {
                ConnectionHubScreen(onBack: { showSyncHub = false })
            }

            Button(action: onReset) {
                Text("Reset Onboarding (Debug)")
                    .font(AgedManuscriptTheme.Fonts.sansLabel(size: 13, weight: .medium))
                    .foregroundColor(AgedManuscriptTheme.Colors.crimsonAccent)
                    .padding()
            }
        }
        .padding(24)
        .agedManuscriptBackground()
    }

    @State private var showSyncHub: Bool = false
}

#Preview("App Coordinator") {
    ContentView()
}

#Preview("Workspace Rehydrated") {
    MainWorkspacePlaceholderView(
        workspacePath: "notes",
        onReset: {}
    )
}
