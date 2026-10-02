//
//  ConnectionHubViewModel.swift
//  OretIOS
//
//  ViewModel for Connection Hub screen and device status
//  Conforms to Stitch Specification 1222f321421342328b0c91c2ab942de3
//

import Foundation
import Observation

#if canImport(SharedLogic)
import SharedLogic
#endif

@Observable
public final class ConnectionHubViewModel {
    public var localDevice: LocalDeviceInfo
    public var peerDevice: PeerDeviceInfo?
    public var syncState: DeviceSyncState
    public var p2pVersion: String = "P2P v1.4"

    // Sheet / Navigation State
    public var showHostPairingSheet: Bool = false
    public var showScanCameraSheet: Bool = false
    public var errorMessage: String? = nil

    public init(
        localDevice: LocalDeviceInfo = .sample,
        peerDevice: PeerDeviceInfo? = .sample,
        syncState: DeviceSyncState = .synced(syncedAt: "Today at 14:20")
    ) {
        self.localDevice = localDevice
        self.peerDevice = peerDevice
        self.syncState = syncState
    }

    // MARK: - Actions

    public func startHostMode() {
        showHostPairingSheet = true
    }

    public func startScanMode() {
        showScanCameraSheet = true
    }

    public func disconnectPeer() {
        self.peerDevice = nil
        self.syncState = .disconnected
    }

    public func setConnected(peer: PeerDeviceInfo) {
        self.peerDevice = peer
        self.syncState = .connected(peerName: peer.deviceName)
    }

    public func setSynced() {
        self.syncState = .synced(syncedAt: "Just now")
    }
}
