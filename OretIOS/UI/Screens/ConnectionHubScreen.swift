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
                onCancel: {
                    viewModel.showHostPairingSheet = false
                }
            )
        }
        // Camera Scanner Modal Sheet (Simulated or Camera Capture)
        .sheet(isPresented: $viewModel.showScanCameraSheet) {
            CameraScannerMockSheet(
                isPresented: $viewModel.showScanCameraSheet,
                onScannedPayload: { _ in
                    viewModel.showScanCameraSheet = false
                    viewModel.setConnected(peer: .sample)
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

// MARK: - Camera Scanner Sheet Helper
private struct CameraScannerMockSheet: View {
    @Binding var isPresented: Bool
    let onScannedPayload: (String) -> Void

    var body: some View {
        VStack(spacing: 24) {
            HStack {
                Button("Cancel") {
                    isPresented = false
                }
                .font(AgedManuscriptTheme.Fonts.sansBody(size: 14, weight: .medium))
                .foregroundColor(AgedManuscriptTheme.Colors.inkSecondary)

                Spacer()

                Text("Scan Peer QR Code")
                    .font(AgedManuscriptTheme.Fonts.serifTitle(size: 17, weight: .semibold))
                    .foregroundColor(AgedManuscriptTheme.Colors.inkPrimary)

                Spacer()

                Color.clear.frame(width: 48, height: 20)
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)

            Spacer()

            // Viewfinder reticle
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(AgedManuscriptTheme.Colors.inkDark, lineWidth: 3)
                    .frame(width: 240, height: 240)

                Image(systemName: "viewfinder")
                    .font(.system(size: 180, weight: .ultraLight))
                    .foregroundColor(AgedManuscriptTheme.Colors.inkSecondary.opacity(0.4))
            }

            Text("Align peer pairing QR code within frame")
                .font(AgedManuscriptTheme.Fonts.sansBody(size: 13, weight: .regular))
                .foregroundColor(AgedManuscriptTheme.Colors.inkSecondary)

            Spacer()

            // Connect button for simulation
            Button(action: {
                onScannedPayload(PairingPayload.sample.formattedJson())
            }) {
                Text("Simulate Successful Scan")
                    .font(AgedManuscriptTheme.Fonts.sansBody(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(AgedManuscriptTheme.Colors.inkDark)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .agedManuscriptBackground()
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
