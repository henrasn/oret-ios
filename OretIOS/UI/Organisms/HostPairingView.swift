//
//  HostPairingView.swift
//  OretIOS
//
//  Organism: Host Mode Pairing View (Aged Manuscript theme)
//  Conforms to Stitch Specification c11640a5ea8b4d56beb95ea6e1f2a248
//

import SwiftUI

public struct HostPairingView: View {
    @Bindable public var viewModel: HostPairingViewModel
    public let onCancel: () -> Void

    public init(
        viewModel: HostPairingViewModel,
        onCancel: @escaping () -> Void
    ) {
        self.viewModel = viewModel
        self.onCancel = onCancel
    }

    public var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 20) {
                // 1. Title & Explanatory Subtitle
                VStack(spacing: 6) {
                    Text("Scan with Your Other Device")
                        .font(AgedManuscriptTheme.Fonts.serifTitle(size: 22, weight: .semibold))
                        .foregroundColor(AgedManuscriptTheme.Colors.inkPrimary)
                        .multilineTextAlignment(.center)
                        .tracking(-0.3)

                    Text("Open the sync screen on your desktop or second phone and scan this code to link devices.")
                        .font(AgedManuscriptTheme.Fonts.sansBody(size: 14, weight: .regular))
                        .foregroundColor(AgedManuscriptTheme.Colors.inkSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(2)
                        .frame(maxWidth: 320)
                }
                .padding(.top, 4)

                // 2. Upfront Review Device Chooser Segment
                ReviewChooserSegment(
                    selectedRole: $viewModel.selectedRole,
                    rememberPreference: $viewModel.rememberPreference,
                    isLocked: viewModel.isPeerConnected
                )

                // 3. Crisp Vector QR Matrix Card
                QrCodeVectorView(
                    size: 200,
                    payloadString: viewModel.payload.formattedJson()
                )

                // 4. Connect Window Countdown Chip
                CountdownBadge(remainingSeconds: viewModel.remainingSeconds)

                // 5. Pairing Code Pill & TLS Fingerprint
                VStack(spacing: 6) {
                    HStack(spacing: 6) {
                        Text("CODE")
                            .font(AgedManuscriptTheme.Fonts.sansLabel(size: 10, weight: .semibold))
                            .foregroundColor(AgedManuscriptTheme.Colors.inkSecondary)
                            .tracking(0.6)

                        Text(viewModel.pairCodeLabel)
                            .font(AgedManuscriptTheme.Fonts.monoCode(size: 13, weight: .bold))
                            .foregroundColor(AgedManuscriptTheme.Colors.inkPrimary)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color(hex: "#FAF3E0"))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(AgedManuscriptTheme.Colors.parchmentBorder.opacity(0.8), lineWidth: 1)
                    )

                    Text(viewModel.fingerprintLabel)
                        .font(AgedManuscriptTheme.Fonts.monoCode(size: 11, weight: .regular))
                        .foregroundColor(AgedManuscriptTheme.Colors.inkSecondary)
                }

                // 6. Manual Pairing Payload Snippet (JSON Box)
                JsonPayloadBox(jsonContent: viewModel.payload.formattedJson())

                // 7. Network Listening Status & Cancel Pairing Button
                VStack(spacing: 12) {
                    // Pulsating Status Indicator
                    HStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(AgedManuscriptTheme.Colors.statusGreen.opacity(0.3))
                                .frame(width: 14, height: 14)

                            Circle()
                                .fill(AgedManuscriptTheme.Colors.statusGreen)
                                .frame(width: 8, height: 8)
                        }

                        Text("Listening on local network...")
                            .font(AgedManuscriptTheme.Fonts.sansBody(size: 13, weight: .regular))
                            .foregroundColor(AgedManuscriptTheme.Colors.inkSecondary)
                    }

                    // Cancel Pairing Button
                    Button(action: onCancel) {
                        Text("Cancel Pairing")
                            .font(AgedManuscriptTheme.Fonts.sansBody(size: 14, weight: .medium))
                            .foregroundColor(AgedManuscriptTheme.Colors.errorRed)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(AgedManuscriptTheme.Colors.errorRed.opacity(0.06))
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
        }
    }
}

#Preview("Host Pairing View") {
    let vm = HostPairingViewModel()
    HostPairingView(
        viewModel: vm,
        onCancel: {}
    )
    .agedManuscriptBackground()
}
