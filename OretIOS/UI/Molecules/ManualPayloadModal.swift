//
//  ManualPayloadModal.swift
//  OretIOS
//
//  Molecule: Client Manual Payload Paste/Entry & Scanner Modal
//  Conforms to Aged Manuscript theme tokens & device_connection_and_sync.md Section 4.2
//

import SwiftUI

public struct ManualPayloadModal: View {
    @Bindable public var viewModel: ClientConnectorViewModel
    @Binding public var isPresented: Bool
    public var onConnectSuccess: (() -> Void)?

    public init(
        viewModel: ClientConnectorViewModel,
        isPresented: Binding<Bool>,
        onConnectSuccess: (() -> Void)? = nil
    ) {
        self.viewModel = viewModel
        self._isPresented = isPresented
        self.onConnectSuccess = onConnectSuccess
    }

    public var body: some View {
        ZStack {
            // Backdrop
            Color(hex: "#1E1C10")
                .opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    isPresented = false
                }

            // Modal Shell
            VStack(spacing: 0) {
                // Top Header Bar
                headerBar

                Divider()
                    .background(AgedManuscriptTheme.Colors.parchmentBorder)

                // Segmented Tab Chooser
                tabSegmentBar
                    .padding(.horizontal, 20)
                    .padding(.top, 16)

                // Content for selected tab
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 16) {
                        if viewModel.selectedTab == .manualInput {
                            manualInputSection
                        } else {
                            cameraScannerSection
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
            }
            .background(AgedManuscriptTheme.Colors.parchment)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(AgedManuscriptTheme.Colors.parchmentBorder, lineWidth: 1.5)
            )
            .shadow(color: Color.black.opacity(0.15), radius: 24, y: 8)
            .padding(.horizontal, 16)
            .padding(.vertical, 32)
        }
    }

    // MARK: - Header Bar

    private var headerBar: some View {
        HStack {
            Button(action: {
                isPresented = false
            }) {
                Text("Cancel")
                    .font(AgedManuscriptTheme.Fonts.sansBody(size: 14, weight: .medium))
                    .foregroundColor(AgedManuscriptTheme.Colors.inkSecondary)
            }
            .buttonStyle(PlainButtonStyle())

            Spacer()

            Text("Connect to Peer Device")
                .font(AgedManuscriptTheme.Fonts.serifTitle(size: 17, weight: .semibold))
                .foregroundColor(AgedManuscriptTheme.Colors.inkPrimary)

            Spacer()

            Color.clear
                .frame(width: 44, height: 20)
        }
        .padding(.horizontal, 20)
        .frame(height: 52)
        .background(AgedManuscriptTheme.Colors.parchmentField)
    }

    // MARK: - Tab Segment Bar

    private var tabSegmentBar: some View {
        HStack(spacing: 4) {
            ForEach(ConnectorTab.allCases) { tab in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        viewModel.selectedTab = tab
                    }
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: tab.iconName)
                            .font(.system(size: 13, weight: .medium))

                        Text(tab.rawValue)
                            .font(AgedManuscriptTheme.Fonts.sansLabel(size: 13, weight: .medium))
                    }
                    .foregroundColor(
                        viewModel.selectedTab == tab
                            ? AgedManuscriptTheme.Colors.inkPrimary
                            : AgedManuscriptTheme.Colors.inkSecondary
                    )
                    .frame(maxWidth: .infinity)
                    .frame(height: 36)
                    .background(
                        viewModel.selectedTab == tab
                            ? AgedManuscriptTheme.Colors.parchmentCard
                            : Color.clear
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 7))
                    .overlay(
                        RoundedRectangle(cornerRadius: 7)
                            .stroke(
                                viewModel.selectedTab == tab
                                    ? AgedManuscriptTheme.Colors.parchmentBorder
                                    : Color.clear,
                                lineWidth: 1
                            )
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(3)
        .background(AgedManuscriptTheme.Colors.parchmentField)
        .clipShape(RoundedRectangle(cornerRadius: 9))
        .overlay(
            RoundedRectangle(cornerRadius: 9)
                .stroke(AgedManuscriptTheme.Colors.parchmentBorder.opacity(0.8), lineWidth: 1)
        )
    }

    // MARK: - Manual Input Section

    private var manualInputSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Instructions
            VStack(alignment: .leading, spacing: 4) {
                Text("Pairing Payload JSON")
                    .font(AgedManuscriptTheme.Fonts.sansBody(size: 14, weight: .semibold))
                    .foregroundColor(AgedManuscriptTheme.Colors.inkPrimary)

                Text("Paste the JSON snippet from the host device's 'Show QR' screen to pin TLS identity.")
                    .font(AgedManuscriptTheme.Fonts.sansBody(size: 12, weight: .regular))
                    .foregroundColor(AgedManuscriptTheme.Colors.inkSecondary)
                    .lineLimit(2)
            }

            // Quick Action Toolbar: Paste & Clear
            HStack(spacing: 8) {
                Button(action: {
                    #if canImport(UIKit)
                    if let string = UIPasteboard.general.string {
                        viewModel.pasteFromClipboard(text: string)
                    } else {
                        viewModel.pasteFromClipboard(text: PairingPayload.sample.formattedJson())
                    }
                    #else
                    viewModel.pasteFromClipboard(text: PairingPayload.sample.formattedJson())
                    #endif
                }) {
                    HStack(spacing: 5) {
                        Image(systemName: "doc.on.clipboard")
                            .font(.system(size: 12, weight: .medium))
                        Text("Paste from Clipboard")
                            .font(AgedManuscriptTheme.Fonts.sansLabel(size: 12, weight: .medium))
                    }
                    .foregroundColor(AgedManuscriptTheme.Colors.inkPrimary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(AgedManuscriptTheme.Colors.parchmentCard)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(AgedManuscriptTheme.Colors.parchmentBorder, lineWidth: 1)
                    )
                }
                .buttonStyle(PlainButtonStyle())

                if !viewModel.payloadInputText.isEmpty {
                    Button(action: {
                        viewModel.clearInput()
                    }) {
                        Text("Clear")
                            .font(AgedManuscriptTheme.Fonts.sansLabel(size: 12, weight: .regular))
                            .foregroundColor(AgedManuscriptTheme.Colors.inkMuted)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 6)
                    }
                    .buttonStyle(PlainButtonStyle())
                }

                Spacer()
            }

            // Textarea Editor
            ZStack(alignment: .topLeading) {
                TextEditor(text: $viewModel.payloadInputText)
                    .font(AgedManuscriptTheme.Fonts.monoCode(size: 11.5, weight: .regular))
                    .foregroundColor(AgedManuscriptTheme.Colors.inkPrimary)
                    .scrollContentBackground(.hidden)
                    .background(AgedManuscriptTheme.Colors.parchmentCard)
                    .frame(height: 140)
                    .padding(8)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(
                                viewModel.validationError != nil
                                    ? AgedManuscriptTheme.Colors.errorRed.opacity(0.8)
                                    : AgedManuscriptTheme.Colors.parchmentBorder,
                                lineWidth: 1.2
                            )
                    )
                    .onChange(of: viewModel.payloadInputText) { _, _ in
                        viewModel.validateCurrentInput()
                    }

                if viewModel.payloadInputText.isEmpty {
                    Text("{\n  \"device_id\": \"...\",\n  \"resolverDeviceId\": \"...\",\n  \"version\": \"1.4\",\n  \"connection_timeout\": 300,\n  \"fingerprint\": \"...\"\n}")
                        .font(AgedManuscriptTheme.Fonts.monoCode(size: 11.5, weight: .regular))
                        .foregroundColor(AgedManuscriptTheme.Colors.inkMuted.opacity(0.45))
                        .padding(14)
                        .allowsHitTesting(false)
                }
            }

            // Live Validation Feedback
            if let error = viewModel.validationError {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(AgedManuscriptTheme.Colors.errorRed)
                        .padding(.top, 1)

                    Text(error)
                        .font(AgedManuscriptTheme.Fonts.sansLabel(size: 12, weight: .medium))
                        .foregroundColor(AgedManuscriptTheme.Colors.errorRed)
                        .lineLimit(3)

                    Spacer()
                }
                .padding(10)
                .background(AgedManuscriptTheme.Colors.errorContainer)
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(AgedManuscriptTheme.Colors.errorRed.opacity(0.3), lineWidth: 1)
                )
            } else if let payload = viewModel.parsedPayload {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 14))
                            .foregroundColor(AgedManuscriptTheme.Colors.statusGreen)

                        Text("Valid Pairing Payload")
                            .font(AgedManuscriptTheme.Fonts.sansLabel(size: 12, weight: .semibold))
                            .foregroundColor(AgedManuscriptTheme.Colors.inkPrimary)

                        Spacer()

                        Text("P2P v\(payload.version)")
                            .font(AgedManuscriptTheme.Fonts.monoCode(size: 10, weight: .bold))
                            .foregroundColor(AgedManuscriptTheme.Colors.inkSecondary)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(AgedManuscriptTheme.Colors.parchment)
                            .cornerRadius(4)
                    }

                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 1) {
                            Text("Peer Device")
                                .font(AgedManuscriptTheme.Fonts.sansLabel(size: 10, weight: .regular))
                                .foregroundColor(AgedManuscriptTheme.Colors.inkSecondary)
                            Text(payload.deviceId)
                                .font(AgedManuscriptTheme.Fonts.monoCode(size: 11, weight: .medium))
                                .foregroundColor(AgedManuscriptTheme.Colors.inkPrimary)
                        }

                        Divider().frame(height: 24)

                        VStack(alignment: .leading, spacing: 1) {
                            Text("Assigned Resolver")
                                .font(AgedManuscriptTheme.Fonts.sansLabel(size: 10, weight: .regular))
                                .foregroundColor(AgedManuscriptTheme.Colors.inkSecondary)
                            Text(viewModel.designatedResolverDescription)
                                .font(AgedManuscriptTheme.Fonts.monoCode(size: 11, weight: .semibold))
                                .foregroundColor(AgedManuscriptTheme.Colors.inkPrimary)
                        }
                    }
                }
                .padding(10)
                .background(AgedManuscriptTheme.Colors.statusGreen.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(AgedManuscriptTheme.Colors.statusGreen.opacity(0.3), lineWidth: 1)
                )
            }

            // Primary Connect Button
            Button(action: {
                Task {
                    let success = await viewModel.connectWithPayload()
                    if success {
                        isPresented = false
                        onConnectSuccess?()
                    }
                }
            }) {
                HStack(spacing: 8) {
                    if viewModel.isConnecting {
                        ProgressView()
                            .tint(.white)
                        Text("Verifying TLS Handshake...")
                            .font(AgedManuscriptTheme.Fonts.sansBody(size: 14, weight: .semibold))
                    } else {
                        Image(systemName: "link")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Connect with Payload")
                            .font(AgedManuscriptTheme.Fonts.sansBody(size: 14, weight: .semibold))
                    }
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 46)
                .background(
                    viewModel.isValidPayload && !viewModel.isConnecting
                        ? AgedManuscriptTheme.Colors.inkDark
                        : AgedManuscriptTheme.Colors.parchmentBorder
                )
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .disabled(!viewModel.isValidPayload || viewModel.isConnecting)
            .buttonStyle(PlainButtonStyle())
            .padding(.top, 4)
        }
    }

    // MARK: - Camera Scanner Section

    private var cameraScannerSection: some View {
        VStack(spacing: 20) {
            // Scanner Viewfinder Reticle
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(AgedManuscriptTheme.Colors.inkDark, lineWidth: 2.5)
                    .frame(width: 220, height: 220)
                    .background(Color(hex: "#1E1C10").opacity(0.04))

                Image(systemName: "viewfinder")
                    .font(.system(size: 160, weight: .ultraLight))
                    .foregroundColor(AgedManuscriptTheme.Colors.inkSecondary.opacity(0.4))
            }

            VStack(spacing: 4) {
                Text("Align Host QR Code")
                    .font(AgedManuscriptTheme.Fonts.sansBody(size: 14, weight: .semibold))
                    .foregroundColor(AgedManuscriptTheme.Colors.inkPrimary)

                Text("Point camera at the QR code displayed on the peer device to automatically pair.")
                    .font(AgedManuscriptTheme.Fonts.sansBody(size: 12, weight: .regular))
                    .foregroundColor(AgedManuscriptTheme.Colors.inkSecondary)
                    .multilineTextAlignment(.center)
            }

            // Simulate Scan Action
            Button(action: {
                viewModel.simulateScanSuccess()
                isPresented = false
                onConnectSuccess?()
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "qrcode.viewfinder")
                    Text("Simulate Successful Scan")
                }
                .font(AgedManuscriptTheme.Fonts.sansBody(size: 13, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 42)
                .background(AgedManuscriptTheme.Colors.inkDark)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .buttonStyle(PlainButtonStyle())

            // Switch to manual input shortcut
            Button(action: {
                withAnimation {
                    viewModel.selectedTab = .manualInput
                }
            }) {
                Text("Or enter payload JSON manually")
                    .font(AgedManuscriptTheme.Fonts.sansLabel(size: 12, weight: .medium))
                    .foregroundColor(AgedManuscriptTheme.Colors.inkSecondary)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

// MARK: - SwiftUI #Previews

#Preview("Manual Payload - Empty") {
    ManualPayloadModal(
        viewModel: ClientConnectorViewModel(initialTab: .manualInput),
        isPresented: .constant(true)
    )
}

#Preview("Manual Payload - Valid JSON") {
    let vm = ClientConnectorViewModel(
        initialTab: .manualInput,
        initialText: PairingPayload.sample.formattedJson()
    )
    ManualPayloadModal(
        viewModel: vm,
        isPresented: .constant(true)
    )
}

#Preview("Manual Payload - Missing Resolver") {
    let malformed = """
    {
      "device_id": "test-dev-123",
      "version": "1.4",
      "connection_timeout": 300,
      "fingerprint": "ab12…34cd"
    }
    """
    let vm = ClientConnectorViewModel(
        initialTab: .manualInput,
        initialText: malformed
    )
    ManualPayloadModal(
        viewModel: vm,
        isPresented: .constant(true)
    )
}

#Preview("Camera Scanner Tab") {
    ManualPayloadModal(
        viewModel: ClientConnectorViewModel(initialTab: .scanner),
        isPresented: .constant(true)
    )
}
