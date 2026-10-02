//
//  ConnectionHubView.swift
//  OretIOS
//
//  Organism: Device Sync & Connection Hub Main Content
//  Conforms to Stitch Specification 1222f321421342328b0c91c2ab942de3
//

import SwiftUI

public struct ConnectionHubView: View {
    @Bindable public var viewModel: ConnectionHubViewModel
    public let onScanQR: () -> Void
    public let onShowQR: () -> Void

    public init(
        viewModel: ConnectionHubViewModel,
        onScanQR: @escaping () -> Void,
        onShowQR: @escaping () -> Void
    ) {
        self.viewModel = viewModel
        self.onScanQR = onScanQR
        self.onShowQR = onShowQR
    }

    public var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 16) {
                // 1. Device Identity Card
                DeviceIdentityView(deviceInfo: viewModel.localDevice)

                // 2. Sync & Connection Status Card
                syncStatusCard

                // 3. Primary Action Buttons (Scan & Show)
                PairingActionRow(
                    onScanQR: onScanQR,
                    onShowQR: onShowQR
                )
                .padding(.top, 4)

                // 4. Paired Peer Info Card (if present)
                if let peer = viewModel.peerDevice {
                    pairedPeerCard(peer: peer)
                }

                // 5. Subtle Archival Security Note
                HStack(spacing: 6) {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 11, weight: .regular))
                    Text("End-to-end encrypted direct peer transfer")
                        .font(AgedManuscriptTheme.Fonts.sansLabel(size: 11, weight: .regular))
                }
                .foregroundColor(AgedManuscriptTheme.Colors.inkMuted)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
        }
    }

    // MARK: - Section 2: Sync & Connection Status Card
    private var syncStatusCard: some View {
        VStack(spacing: 12) {
            // Header Row: STATUS and Protocol Version
            HStack {
                Text("STATUS")
                    .font(AgedManuscriptTheme.Fonts.sansLabel(size: 11, weight: .semibold))
                    .foregroundColor(AgedManuscriptTheme.Colors.inkSecondary)
                    .tracking(0.8)

                Spacer()

                Text(viewModel.p2pVersion)
                    .font(AgedManuscriptTheme.Fonts.monoCode(size: 11, weight: .regular))
                    .foregroundColor(AgedManuscriptTheme.Colors.inkSecondary.opacity(0.8))
            }
            .padding(.bottom, 2)
            .overlay(
                Rectangle()
                    .fill(AgedManuscriptTheme.Colors.parchmentBorder.opacity(0.6))
                    .frame(height: 1),
                alignment: .bottom
            )

            // Direct Connection Row
            HStack {
                Text("Direct Connection")
                    .font(AgedManuscriptTheme.Fonts.sansBody(size: 13, weight: .regular))
                    .foregroundColor(AgedManuscriptTheme.Colors.inkSecondary)

                Spacer()

                HStack(spacing: 8) {
                    Circle()
                        .fill(connectionStatusColor)
                        .frame(width: 9, height: 9)
                        .overlay(
                            Circle()
                                .stroke(AgedManuscriptTheme.Colors.parchmentBorder, lineWidth: 2)
                        )

                    Text(viewModel.syncState.displayText)
                        .font(AgedManuscriptTheme.Fonts.sansBody(size: 13, weight: .regular))
                        .foregroundColor(AgedManuscriptTheme.Colors.inkPrimary)
                }
            }

            // Note State Row
            HStack {
                Text("Note State")
                    .font(AgedManuscriptTheme.Fonts.sansBody(size: 13, weight: .regular))
                    .foregroundColor(AgedManuscriptTheme.Colors.inkSecondary)

                Spacer()

                HStack(spacing: 5) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(AgedManuscriptTheme.Colors.statusGreen)

                    Text("Synced on all devices")
                        .font(AgedManuscriptTheme.Fonts.sansLabel(size: 12, weight: .medium))
                        .foregroundColor(AgedManuscriptTheme.Colors.statusGreen)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(AgedManuscriptTheme.Colors.statusGreenBg)
                .clipShape(RoundedRectangle(cornerRadius: 4))
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(AgedManuscriptTheme.Colors.statusGreenBorder, lineWidth: 1)
                )
            }

            // Last Synced Note Row
            if let peer = viewModel.peerDevice {
                HStack(spacing: 6) {
                    Image(systemName: "clock")
                        .font(.system(size: 11, weight: .regular))
                        .opacity(0.7)

                    Text(peer.lastSyncedDescription)
                        .font(AgedManuscriptTheme.Fonts.sansLabel(size: 11, weight: .regular))
                        .lineLimit(1)

                    Spacer()
                }
                .foregroundColor(AgedManuscriptTheme.Colors.inkSecondary)
                .padding(.top, 4)
                .overlay(
                    Rectangle()
                        .fill(AgedManuscriptTheme.Colors.parchmentBorder.opacity(0.6))
                        .frame(height: 1),
                    alignment: .top
                )
            }
        }
        .padding(16)
        .background(AgedManuscriptTheme.Colors.parchmentField)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(AgedManuscriptTheme.Colors.parchmentBorder, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.04), radius: 3, y: 1)
    }

    // MARK: - Section 4: Paired Peer Info Card
    private func pairedPeerCard(peer: PeerDeviceInfo) -> some View {
        HStack {
            HStack(spacing: 12) {
                // Peer Icon Container
                ZStack {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(AgedManuscriptTheme.Colors.parchment)
                        .frame(width: 36, height: 36)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color(hex: "#E0D3B5"), lineWidth: 1)
                        )

                    Image(systemName: "display")
                        .font(.system(size: 18, weight: .regular))
                        .foregroundColor(AgedManuscriptTheme.Colors.inkPrimary)
                }

                // Peer Name & Address
                VStack(alignment: .leading, spacing: 2) {
                    Text(peer.deviceName)
                        .font(AgedManuscriptTheme.Fonts.sansBody(size: 14, weight: .semibold))
                        .foregroundColor(AgedManuscriptTheme.Colors.inkPrimary)

                    Text(peer.address)
                        .font(AgedManuscriptTheme.Fonts.monoCode(size: 11, weight: .regular))
                        .foregroundColor(AgedManuscriptTheme.Colors.inkSecondary)
                }
            }

            Spacer()

            // Green Trusted Peer Badge
            if peer.isTrusted {
                HStack(spacing: 5) {
                    Circle()
                        .fill(AgedManuscriptTheme.Colors.statusGreen)
                        .frame(width: 6, height: 6)

                    Text("Trusted Peer")
                        .font(AgedManuscriptTheme.Fonts.sansLabel(size: 11, weight: .medium))
                        .foregroundColor(AgedManuscriptTheme.Colors.statusGreen)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(AgedManuscriptTheme.Colors.trustedPeerBg)
                .clipShape(RoundedRectangle(cornerRadius: 4))
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(AgedManuscriptTheme.Colors.trustedPeerBorder, lineWidth: 1)
                )
            }
        }
        .padding(14)
        .background(Color(hex: "#EFE8D5"))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(AgedManuscriptTheme.Colors.parchmentBorder, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.02), radius: 2, y: 1)
    }

    private var connectionStatusColor: Color {
        switch viewModel.syncState {
        case .connected, .synced:
            return AgedManuscriptTheme.Colors.statusGreen
        case .hosting:
            return AgedManuscriptTheme.Colors.amberWindowText
        case .scanning:
            return Color.blue
        case .conflictsDetected:
            return Color.orange
        case .connectionLost:
            return AgedManuscriptTheme.Colors.errorRed
        case .disconnected, .syncInProgress:
            return Color(hex: "#9E9B90")
        }
    }
}

#Preview("Connection Hub View") {
    let vm = ConnectionHubViewModel()
    ConnectionHubView(
        viewModel: vm,
        onScanQR: {},
        onShowQR: {}
    )
    .agedManuscriptBackground()
}
