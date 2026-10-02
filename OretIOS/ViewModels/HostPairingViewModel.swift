//
//  HostPairingViewModel.swift
//  OretIOS
//
//  ViewModel for Host Mode Pairing & Upfront Resolver Selection
//  Conforms to Stitch Specification c11640a5ea8b4d56beb95ea6e1f2a248
//

import Foundation
import Observation

#if canImport(SharedLogic)
import SharedLogic
#endif

@Observable
public final class HostPairingViewModel {
    public var selectedRole: ResolverRole {
        didSet {
            recalculatePayload()
        }
    }
    public var rememberPreference: Bool
    public var remainingSeconds: Int
    public var isListening: Bool
    public var isPeerConnected: Bool
    public var payload: PairingPayload

    public init(
        initialRole: ResolverRole = .thisDevice,
        rememberPreference: Bool = true,
        connectWindowSeconds: Int = 272,
        basePayload: PairingPayload = .sample
    ) {
        self.selectedRole = initialRole
        self.rememberPreference = rememberPreference
        self.remainingSeconds = connectWindowSeconds
        self.isListening = true
        self.isPeerConnected = false
        var p = basePayload
        p.resolverDeviceId = initialRole == .thisDevice ? p.deviceId : "peer"
        self.payload = p
    }

    // MARK: - Role Selection & Live Payload Regeneration

    private func recalculatePayload() {
        if selectedRole == .thisDevice {
            payload.resolverDeviceId = payload.deviceId
        } else {
            payload.resolverDeviceId = "peer"
        }
    }

    // MARK: - Timer Handling

    public func tick() {
        guard remainingSeconds > 0 else {
            isListening = false
            return
        }
        remainingSeconds -= 1
    }

    // MARK: - Presentation Helpers

    public var pairCodeLabel: String {
        "Pair Code: \(payload.pairCode)"
    }

    public var fingerprintLabel: String {
        "TLS Fingerprint: \(payload.fingerprint)"
    }
}
