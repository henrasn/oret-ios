//
//  DirectorySetupView.swift
//  OretIOS
//
//  Directory Setup Organism for Workspace Initialization (Aged Manuscript theme)
//

import SwiftUI
import Observation

public struct DirectorySetupView: View {
    public var viewModel: DirectorySetupViewModel
    public var onBack: (() -> Void)?
    public let onConfirm: (String) -> Void

    public init(
        viewModel: DirectorySetupViewModel,
        onBack: (() -> Void)? = nil,
        onConfirm: @escaping (String) -> Void
    ) {
        self.viewModel = viewModel
        self.onBack = onBack
        self.onConfirm = onConfirm
    }

    public var body: some View {
        @Bindable var viewModel = viewModel
        VStack(spacing: 0) {
            // MARK: - Top Navigation Bar
            HStack {
                if let onBack = onBack {
                    Button(action: onBack) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(AgedManuscriptTheme.Colors.inkSecondary)
                            .frame(width: 40, height: 40)
                            .background(
                                Circle()
                                    .fill(AgedManuscriptTheme.Colors.parchmentField.opacity(0.6))
                            )
                    }
                    .accessibilityLabel(Text("Go back"))
                } else {
                    Spacer().frame(width: 40)
                }

                Spacer()

                // Status Badge Pill: "STORAGE SETUP"
                HStack(spacing: 6) {
                    Circle()
                        .fill(AgedManuscriptTheme.Colors.oliveSage)
                        .frame(width: 6, height: 6)

                    Text("STORAGE SETUP")
                        .font(AgedManuscriptTheme.Fonts.sansLabel(size: 11, weight: .semibold))
                        .foregroundColor(AgedManuscriptTheme.Colors.inkSecondary)
                        .tracking(0.6)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(AgedManuscriptTheme.Colors.parchmentField)
                .clipShape(Capsule())
                .overlay(
                    Capsule().stroke(AgedManuscriptTheme.Colors.parchmentBorder, lineWidth: 1)
                )
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 8)

            // MARK: - Main Scrollable Content
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header Section
                    VStack(alignment: .leading, spacing: 12) {
                        // Folder Icon Container
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(AgedManuscriptTheme.Colors.parchmentField)
                                .frame(width: 46, height: 46)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(AgedManuscriptTheme.Colors.parchmentBorder, lineWidth: 1)
                                )
                                .shadow(color: Color.black.opacity(0.04), radius: 2, y: 1)

                            Image(systemName: "folder.badge.plus")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(AgedManuscriptTheme.Colors.crimsonAccent)
                        }
                        .padding(.bottom, 4)

                        // Title
                        Text("Set Up Your Working Directory")
                            .font(AgedManuscriptTheme.Fonts.serifTitle(size: 24, weight: .semibold))
                            .foregroundColor(AgedManuscriptTheme.Colors.inkPrimary)
                            .lineSpacing(2)

                        // Subtitle
                        Text("Choose the internal workspace folder where your notes will be stored safely on this phone.")
                            .font(AgedManuscriptTheme.Fonts.sansBody(size: 14, weight: .regular))
                            .foregroundColor(AgedManuscriptTheme.Colors.inkSecondary)
                            .lineSpacing(3)
                    }

                    // Path Input Form Row
                    DirectoryPathRow(
                        folderName: $viewModel.folderName,
                        validationError: viewModel.validationError
                    )

                    // Information Callout Card
                    HStack(alignment: .top, spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color(hex: "#E8DEC6"))
                                .frame(width: 26, height: 26)

                            Image(systemName: "info")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(AgedManuscriptTheme.Colors.crimsonAccent)
                        }
                        .padding(.top, 2)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Local Sandbox")
                                .font(AgedManuscriptTheme.Fonts.sansBody(size: 13, weight: .semibold))
                                .foregroundColor(AgedManuscriptTheme.Colors.inkPrimary)

                            (
                                Text("All notes remain private to this device. An internal ")
                                    .font(AgedManuscriptTheme.Fonts.sansBody(size: 13, weight: .regular))
                                    .foregroundColor(AgedManuscriptTheme.Colors.inkSecondary)
                                +
                                Text(".syncstore/")
                                    .font(AgedManuscriptTheme.Fonts.monoCode(size: 11, weight: .medium))
                                    .foregroundColor(AgedManuscriptTheme.Colors.inkPrimary)
                                +
                                Text(" database is automatically generated for peer synchronization without external cloud dependencies.")
                                    .font(AgedManuscriptTheme.Fonts.sansBody(size: 13, weight: .regular))
                                    .foregroundColor(AgedManuscriptTheme.Colors.inkSecondary)
                            )
                        }
                    }
                    .padding(14)
                    .background(AgedManuscriptTheme.Colors.parchmentField)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(AgedManuscriptTheme.Colors.parchmentBorder, lineWidth: 1)
                    )

                    // Hardware Sandboxing Security Badge
                    HStack {
                        HStack(spacing: 8) {
                            Image(systemName: "shield.checkered")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(AgedManuscriptTheme.Colors.oliveSage)

                            Text("Hardware-level Sandboxing")
                                .font(AgedManuscriptTheme.Fonts.sansLabel(size: 12, weight: .medium))
                                .foregroundColor(AgedManuscriptTheme.Colors.inkPrimary)
                        }

                        Spacer()

                        Text("AES-GCM ready")
                            .font(AgedManuscriptTheme.Fonts.monoCode(size: 11, weight: .medium))
                            .foregroundColor(AgedManuscriptTheme.Colors.inkSecondary)
                    }
                    .padding(12)
                    .background(AgedManuscriptTheme.Colors.parchmentCard.opacity(0.8))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(AgedManuscriptTheme.Colors.parchmentBorder.opacity(0.7), lineWidth: 1)
                    )
                }
                .padding(.horizontal, 24)
                .padding(.top, 12)
                .padding(.bottom, 20)
            }

            // MARK: - Bottom Action Area
            VStack(spacing: 0) {
                Divider()
                    .background(AgedManuscriptTheme.Colors.parchmentBorder)

                PrimaryButton(
                    title: viewModel.isInitializing ? "Initializing Workspace..." : "Confirm & Initialize Workspace",
                    icon: "arrow.right",
                    isTrailingIcon: true,
                    isEnabled: viewModel.isValid && !viewModel.isInitializing
                ) {
                    viewModel.confirmAndInitialize { result in
                        switch result {
                        case .success(let folder):
                            onConfirm(folder)
                        case .failure:
                            break
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 32)
            }
            .background(AgedManuscriptTheme.Colors.parchment)
        }
        .agedManuscriptBackground()
    }
}

#Preview {
    DirectorySetupView(
        viewModel: DirectorySetupViewModel(),
        onBack: {},
        onConfirm: { _ in }
    )
}
