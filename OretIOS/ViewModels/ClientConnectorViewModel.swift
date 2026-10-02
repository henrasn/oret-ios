//
//  ClientConnectorViewModel.swift
//  OretIOS
//
//  ViewModel for Client Connector Mode & Manual Payload Validation
//  Conforms to Stitch Specifications & device_connection_and_sync.md Section 4.2
//

import Foundation
import Observation

#if canImport(SharedLogic)
import SharedLogic
#endif

public enum ConnectorTab: String, CaseIterable, Identifiable {
    case scanner = "Camera Scanner"
    case manualInput = "Manual Entry"

    public var id: String { rawValue }

    public var iconName: String {
        switch self {
        case .scanner:
            return "camera.viewfinder"
        case .manualInput:
            return "keyboard"
        }
    }
}

@Observable
public final class ClientConnectorViewModel {
    public var selectedTab: ConnectorTab
    public var payloadInputText: String
    public var parsedPayload: PairingPayload?
    public var validationError: String?
    public var isConnecting: Bool
    public var connectionSucceeded: Bool
    public var connectedPeer: PeerDeviceInfo?
    public var localDeviceId: String

    public var onConnected: ((PeerDeviceInfo, PairingPayload) -> Void)?

    public init(
        initialTab: ConnectorTab = .manualInput,
        initialText: String = "",
        localDeviceId: String = "dev-pixel8-ab12",
        onConnected: ((PeerDeviceInfo, PairingPayload) -> Void)? = nil
    ) {
        self.selectedTab = initialTab
        self.payloadInputText = initialText
        self.localDeviceId = localDeviceId
        self.onConnected = onConnected
        self.isConnecting = false
        self.connectionSucceeded = false
        self.validationError = nil
        if !initialText.isEmpty {
            _ = validateCurrentInput()
        }
    }

    // MARK: - Validation & Parsing Logic

    @discardableResult
    public func validateCurrentInput() -> Bool {
        let cleanText = payloadInputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanText.isEmpty else {
            self.parsedPayload = nil
            self.validationError = nil
            return false
        }

        do {
            let payload = try PairingPayload.parseAndValidate(jsonString: cleanText)
            self.parsedPayload = payload
            self.validationError = nil
            return true
        } catch let error as PayloadValidationError {
            self.parsedPayload = nil
            self.validationError = error.localizedDescription
            return false
        } catch {
            self.parsedPayload = nil
            self.validationError = error.localizedDescription
            return false
        }
    }

    public var isValidPayload: Bool {
        parsedPayload != nil && validationError == nil
    }

    public var isLocalDesignatedResolver: Bool {
        guard let p = parsedPayload else { return false }
        return p.resolverDeviceId == localDeviceId || p.resolverDeviceId == "local"
    }

    public var designatedResolverDescription: String {
        guard let p = parsedPayload else { return "None" }
        if p.resolverDeviceId == localDeviceId || p.resolverDeviceId == "local" {
            return "This Device (Local Resolver)"
        } else {
            return "Peer Device (\(p.resolverDeviceId))"
        }
    }

    // MARK: - Actions

    public func pasteFromClipboard(text: String) {
        self.payloadInputText = text
        _ = validateCurrentInput()
    }

    public func clearInput() {
        self.payloadInputText = ""
        self.parsedPayload = nil
        self.validationError = nil
    }

    public func connectWithPayload() async -> Bool {
        guard validateCurrentInput(), let payload = parsedPayload else {
            return false
        }

        isConnecting = true
        validationError = nil

        // Simulate TLS connection handshake delay
        try? await Task.sleep(nanoseconds: 300_000_000)

        let peer = PeerDeviceInfo(
            deviceName: "Peer (\(payload.deviceId.prefix(8)))",
            fingerprint: payload.fingerprint,
            address: "\(payload.lanAddress) • TLS 1.3",
            isTrusted: true,
            lastSyncedDescription: "Connected via peer payload"
        )

        self.connectedPeer = peer
        self.connectionSucceeded = true
        self.isConnecting = false

        onConnected?(peer, payload)
        return true
    }

    public func simulateScanSuccess(sampleJson: String? = nil) {
        let json = sampleJson ?? PairingPayload.sample.formattedJson()
        self.payloadInputText = json
        _ = validateCurrentInput()
        Task {
            _ = await connectWithPayload()
        }
    }
}
