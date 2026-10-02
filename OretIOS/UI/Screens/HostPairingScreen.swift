//
//  HostPairingScreen.swift
//  OretIOS
//
//  Mobile Host Mode Pairing Screen (Aged Manuscript theme)
//  Conforms to Stitch Specification c11640a5ea8b4d56beb95ea6e1f2a248
//

import SwiftUI

public struct HostPairingScreen: View {
    @State private var viewModel: HostPairingViewModel
    public let onCancel: () -> Void

    public init(
        viewModel: HostPairingViewModel? = nil,
        onCancel: @escaping () -> Void
    ) {
        self._viewModel = State(initialValue: viewModel ?? HostPairingViewModel())
        self.onCancel = onCancel
    }

    public var body: some View {
        ZStack {
            // Background Parchment Base
            AgedManuscriptTheme.Colors.parchment
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Top Header Bar
                topHeaderBar

                // Scrollable Content
                HostPairingView(
                    viewModel: viewModel,
                    onCancel: onCancel
                )
            }
        }
        // Background 1-second countdown timer task
        .task {
            while !Task.isCancelled && viewModel.remainingSeconds > 0 {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                viewModel.tick()
            }
        }
    }

    // MARK: - Top Header Bar (Stitch c11640a5ea8b4d56beb95ea6e1f2a248)
    private var topHeaderBar: some View {
        HStack {
            Button(action: onCancel) {
                Text("Cancel")
                    .font(AgedManuscriptTheme.Fonts.sansBody(size: 14, weight: .medium))
                    .foregroundColor(AgedManuscriptTheme.Colors.inkSecondary)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 4)
            }
            .buttonStyle(PlainButtonStyle())
            .accessibilityLabel(Text("Cancel Pairing"))

            Spacer()

            Text("Pairing QR Code")
                .font(AgedManuscriptTheme.Fonts.serifTitle(size: 18, weight: .semibold))
                .foregroundColor(AgedManuscriptTheme.Colors.inkPrimary)
                .tracking(-0.2)

            Spacer()

            // Balanced width placeholder for header symmetry
            Color.clear
                .frame(width: 48, height: 20)
                .accessibilityHidden(true)
        }
        .padding(.horizontal, 16)
        .frame(height: 52)
        .overlay(
            Rectangle()
                .fill(AgedManuscriptTheme.Colors.parchmentBorder.opacity(0.6))
                .frame(height: 1),
            alignment: .bottom
        )
    }
}

// MARK: - SwiftUI #Previews

#Preview("Host Pairing Screen - Active Countdown") {
    HostPairingScreen(
        viewModel: HostPairingViewModel(
            initialRole: .thisDevice,
            connectWindowSeconds: 272
        ),
        onCancel: {}
    )
}

#Preview("Host Pairing Screen - Other Device Chooser") {
    HostPairingScreen(
        viewModel: HostPairingViewModel(
            initialRole: .otherDevice,
            connectWindowSeconds: 65
        ),
        onCancel: {}
    )
}

#Preview("Host Pairing Screen - Window Expired") {
    HostPairingScreen(
        viewModel: HostPairingViewModel(
            initialRole: .thisDevice,
            connectWindowSeconds: 0
        ),
        onCancel: {}
    )
}
