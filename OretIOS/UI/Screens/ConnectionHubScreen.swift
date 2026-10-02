//
//  ConnectionHubScreen.swift
//  OretIOS
//
//  Mobile Connection Hub Screen (Aged Manuscript theme)
//  Conforms to Stitch Specification 1222f321421342328b0c91c2ab942de3
//

import SwiftUI

public struct ConnectionHubScreen: View {
    @State private var viewModel: ConnectionHubViewModel
    public var onBack: (() -> Void)?
    public var onSettings: (() -> Void)?

    public init(
        viewModel: ConnectionHubViewModel? = nil,
        onBack: (() -> Void)? = nil,
        onSettings: (() -> Void)? = nil
    ) {
        self._viewModel = State(initialValue: viewModel ?? ConnectionHubViewModel())
        self.onBack = onBack
        self.onSettings = onSettings
    }

    public var body: some View {
        ZStack {
            // Background Parchment Base
            AgedManuscriptTheme.Colors.parchment
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Top Navigation Bar
                topNavigationBar

                // Scrollable Content
                ConnectionHubView(
                    viewModel: viewModel,
                    onScanQR: {
                        viewModel.startScanMode()
                    },
                    onShowQR: {
                        viewModel.startHostMode()
                    }
                )
            }
        }
        // Host Mode Pairing Modal Sheet
        .sheet(isPresented: $viewModel.showHostPairingSheet) {
            HostPairingScreen(
                viewModel: viewModel.hostPairingVM,
                onCancel: {
                    viewModel.showHostPairingSheet = false
                }
            )
        }
        // Client Mode Connector & Manual Payload Entry Modal Sheet
        .sheet(isPresented: $viewModel.showScanCameraSheet) {
            ManualPayloadModal(
                viewModel: viewModel.clientConnectorVM,
                isPresented: $viewModel.showScanCameraSheet,
                onConnectSuccess: {
                    viewModel.showScanCameraSheet = false
                }
            )
        }
    }

    // MARK: - Top Navigation Bar (Stitch 1222f321421342328b0c91c2ab942de3)
    private var topNavigationBar: some View {
        HStack {
            // Leading Back Chevron
            Button(action: {
                onBack?()
            }) {
                Image(systemName: "chevron.backward")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AgedManuscriptTheme.Colors.inkPrimary)
                    .frame(width: 36, height: 36)
                    .background(Color.clear)
                    .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
            .accessibilityLabel(Text("Back to Notes"))

            Spacer()

            // Center Title
            Text("Device Sync")
                .font(AgedManuscriptTheme.Fonts.serifTitle(size: 18, weight: .semibold))
                .foregroundColor(AgedManuscriptTheme.Colors.inkPrimary)

            Spacer()

            // Trailing Settings Gear
            Button(action: {
                onSettings?()
            }) {
                Image(systemName: "gearshape")
                    .font(.system(size: 17, weight: .regular))
                    .foregroundColor(AgedManuscriptTheme.Colors.inkSecondary)
                    .frame(width: 36, height: 36)
                    .background(Color.clear)
                    .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
            .accessibilityLabel(Text("Sync Settings"))
        }
        .padding(.horizontal, 16)
        .frame(height: 54)
        .background(AgedManuscriptTheme.Colors.parchment.opacity(0.95))
        .overlay(
            Rectangle()
                .fill(AgedManuscriptTheme.Colors.parchmentBorder)
                .frame(height: 1),
            alignment: .bottom
        )
    }
}


// MARK: - SwiftUI #Previews

#Preview("Standard Synced Hub") {
    ConnectionHubScreen()
}

#Preview("No Paired Peer Hub") {
    let vm = ConnectionHubViewModel(
        localDevice: .sample,
        peerDevice: nil,
        syncState: .disconnected
    )
    ConnectionHubScreen(viewModel: vm)
}

#Preview("Active Hosting Hub") {
    let vm = ConnectionHubViewModel(
        localDevice: .sample,
        peerDevice: nil,
        syncState: .hosting(secondsRemaining: 272)
    )
    ConnectionHubScreen(viewModel: vm)
}
