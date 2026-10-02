//
//  ContentView.swift
//  OretIOS
//
//  Main Navigation Flow Coordinator
//

import SwiftUI

enum AppFlowState {
    case onboarding
    case directorySetup
    case mainWorkspace
}

struct ContentView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    @AppStorage("localPath") private var localPath: String = ""
    @State private var flowState: AppFlowState = .onboarding

    var body: some View {
        Group {
            switch currentFlowState {
            case .onboarding:
                OnboardingScreen {
                    hasCompletedOnboarding = true
                    flowState = .directorySetup
                }

            case .directorySetup:
                DirectorySetupScreen(
                    onBack: hasCompletedOnboarding ? nil : {
                        flowState = .onboarding
                    },
                    onWorkspaceInitialized: { folder in
                        localPath = folder
                        flowState = .mainWorkspace
                    }
                )

            case .mainWorkspace:
                MainWorkspacePlaceholderView(
                    workspacePath: localPath,
                    onReset: {
                        hasCompletedOnboarding = false
                        localPath = ""
                        flowState = .onboarding
                    }
                )
            }
        }
        .agedManuscriptBackground()
    }

    private var currentFlowState: AppFlowState {
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
}

#Preview {
    ContentView()
}
