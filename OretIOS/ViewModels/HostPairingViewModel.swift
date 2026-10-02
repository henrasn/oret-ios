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
    public var localDeviceId: String
    public var peerDeviceId: String

    public init(
        initialRole: ResolverRole = .thisDevice,
        rememberPreference: Bool = true,
        connectWindowSeconds: Int = 272,
        localDeviceId: String? = nil,
        peerDeviceId: String? = nil,
        basePayload: PairingPayload = .sample
    ) {
        self.selectedRole = initialRole
        self.rememberPreference = rememberPreference
        self.remainingSeconds = connectWindowSeconds
        self.isListening = true
        self.isPeerConnected = false

        let resolvedLocalId = localDeviceId ?? basePayload.deviceId
        let resolvedPeerId = peerDeviceId ?? "peer"
        self.localDeviceId = resolvedLocalId
        self.peerDeviceId = resolvedPeerId

        var p = basePayload
        p.deviceId = resolvedLocalId
        p.resolverDeviceId = initialRole == .thisDevice ? resolvedLocalId : resolvedPeerId
        self.payload = p
    }

    // MARK: - Role Selection & Live Payload Regeneration

    private func recalculatePayload() {
        guard !isPeerConnected else { return } // Connection guard prevents race conditions
        let targetResolverId = (selectedRole == .thisDevice) ? localDeviceId : peerDeviceId
        payload.resolverDeviceId = targetResolverId
    }

    /// Selects review role and regenerates payload with designated resolverDeviceId
    public func selectReviewDevice(role: ResolverRole) {
        guard !isPeerConnected else { return }
        self.selectedRole = role
    }

    /// Explicitly updates designated resolverDeviceId and synchronizes role chooser state
    public func setResolverDeviceId(_ resolverDeviceId: String) {
        guard !isPeerConnected else { return }
        payload.resolverDeviceId = resolverDeviceId
        if resolverDeviceId == localDeviceId {
            selectedRole = .thisDevice
        } else {
            selectedRole = .otherDevice
        }
    }

    /// Generates a copy of the payload for a custom designated resolverDeviceId
    public func generatePayload(withResolverId resolverId: String) -> PairingPayload {
        var copy = payload
        copy.resolverDeviceId = resolverId
        return copy
    }

    /// Locks review chooser when peer establishes TLS handshake
    public func markPeerConnected(peerId: String? = nil) {
        if let peerId = peerId, !peerId.isEmpty {
            self.peerDeviceId = peerId
            if selectedRole == .otherDevice {
                payload.resolverDeviceId = peerId
            }
        }
        self.isPeerConnected = true
        self.isListening = false
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
