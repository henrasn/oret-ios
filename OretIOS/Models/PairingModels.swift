//
//  PairingModels.swift
//  OretIOS
//
//  Data models and state representations for Connection Hub & QR Pairing
//  Conforms to Stitch Specs: 1222f321421342328b0c91c2ab942de3 & c11640a5ea8b4d56beb95ea6e1f2a248
//

import Foundation

#if canImport(SharedLogic)
import SharedLogic
#endif

// MARK: - Resolver Role (Upfront Chooser)
public enum ResolverRole: String, CaseIterable, Identifiable, Equatable {
    case thisDevice = "local"
    case otherDevice = "peer"

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .thisDevice:
            return "This Device"
        case .otherDevice:
            return "The Other Device"
        }
    }

    public var subtitle: String {
        switch self {
        case .thisDevice:
            return "Recommended"
        case .otherDevice:
            return "Peer Resolver"
        }
    }

    public var iconName: String {
        switch self {
        case .thisDevice:
            return "iphone"
        case .otherDevice:
            return "display"
        }
    }

    #if canImport(SharedLogic)
    public init(kmpModel: ResolverRoleModel) {
        switch kmpModel {
        case .thisDevice: self = .thisDevice
        case .otherDevice: self = .otherDevice
        @unknown default: self = .thisDevice
        }
    }
    #endif
}

// MARK: - Device Sync & Connection State
public enum DeviceSyncState: Equatable {
    case disconnected
    case hosting(secondsRemaining: Int)
    case scanning
    case connected(peerName: String)
    case syncInProgress(percentage: Int)
    case synced(syncedAt: String)
    case conflictsDetected(count: Int)
    case connectionLost

    public var displayText: String {
        switch self {
        case .disconnected:
            return "Disconnected / Idle"
        case .hosting(let seconds):
            let mins = seconds / 60
            let secs = seconds % 60
            return String(format: "Hosting (Waiting… %02d:%02d)", mins, secs)
        case .scanning:
            return "Scanning for peer…"
        case .connected(let peerName):
            return "Connected to \(peerName)"
        case .syncInProgress(let percentage):
            return "Sync in progress (\(percentage)%)"
        case .synced:
            return "Synced on all devices"
        case .conflictsDetected(let count):
            return "\(count) Conflicts Detected"
        case .connectionLost:
            return "Connection Lost / Timed Out"
        }
    }

    public var isConnected: Bool {
        switch self {
        case .connected, .syncInProgress, .synced:
            return true
        default:
            return false
        }
    }
}

// MARK: - Local Device Identity
public struct LocalDeviceInfo: Equatable {
    public var deviceName: String
    public var fingerprint: String
    public var roleCaption: String

    public init(
        deviceName: String = "Pixel 8 Pro",
        fingerprint: String = "ab12…8f3c",
        roleCaption: String = "Primary Local Vault"
    ) {
        self.deviceName = deviceName
        self.fingerprint = fingerprint
        self.roleCaption = roleCaption
    }

    #if canImport(SharedLogic)
    public init(kmpModel: LocalDeviceInfoModel) {
        self.init(
            deviceName: kmpModel.deviceName,
            fingerprint: kmpModel.fingerprint,
            roleCaption: kmpModel.roleDescription
        )
    }
    #endif

    public static let sample = LocalDeviceInfo(
        deviceName: "Pixel 8 Pro",
        fingerprint: "ab12…8f3c",
        roleCaption: "Primary Local Vault"
    )
}

// MARK: - Paired Peer Device Info
public struct PeerDeviceInfo: Equatable {
    public var deviceName: String
    public var fingerprint: String
    public var address: String
    public var isTrusted: Bool
    public var lastSyncedDescription: String

    public init(
        deviceName: String = "MacBook Air",
        fingerprint: String = "e7a9…2b41",
        address: String = "192.168.1.42 • TLS 1.3",
        isTrusted: Bool = true,
        lastSyncedDescription: String = "Last synced today at 14:20 with MacBook Air"
    ) {
        self.deviceName = deviceName
        self.fingerprint = fingerprint
        self.address = address
        self.isTrusted = isTrusted
        self.lastSyncedDescription = lastSyncedDescription
    }

    #if canImport(SharedLogic)
    public init(kmpModel: PeerDeviceInfoModel) {
        self.init(
            deviceName: kmpModel.deviceName,
            fingerprint: kmpModel.deviceFingerprint,
            address: kmpModel.address,
            isTrusted: kmpModel.isTrusted,
            lastSyncedDescription: kmpModel.lastSyncedDescription
        )
    }
    #endif

    public static let sample = PeerDeviceInfo(
        deviceName: "MacBook Air",
        fingerprint: "e7a9…2b41",
        address: "192.168.1.42 • TLS 1.3",
        isTrusted: true,
        lastSyncedDescription: "Last synced today at 14:20 with MacBook Air"
    )
}

// MARK: - Pairing Payload Model
public struct PairingPayload: Equatable {
    public var deviceId: String
    public var resolverDeviceId: String
    public var version: String
    public var connectionTimeout: Int
    public var fingerprint: String
    public var lanAddress: String
    public var pairCode: String

    public init(
        deviceId: String = "ab128f3c",
        resolverDeviceId: String = "ab128f3c",
        version: String = "1.4",
        connectionTimeout: Int = 300,
        fingerprint: String = "e7a9…2b41",
        lanAddress: String = "192.168.1.42:8080",
        pairCode: String = "849-204"
    ) {
        self.deviceId = deviceId
        self.resolverDeviceId = resolverDeviceId
        self.version = version
        self.connectionTimeout = connectionTimeout
        self.fingerprint = fingerprint
        self.lanAddress = lanAddress
        self.pairCode = pairCode
    }

    #if canImport(SharedLogic)
    public init(kmpModel: PairingPayloadModel) {
        self.init(
            deviceId: kmpModel.deviceId,
            resolverDeviceId: kmpModel.resolverDeviceId,
            version: kmpModel.version,
            connectionTimeout: Int(kmpModel.connectionTimeout),
            fingerprint: kmpModel.fingerprint,
            lanAddress: kmpModel.lanAddress,
            pairCode: kmpModel.pairCode
        )
    }
    #endif

    /// Formats payload into pretty-printed JSON matching Stitch c11640a5ea8b4d56beb95ea6e1f2a248
    public func formattedJson() -> String {
        return """
        {
          "device_id": "\(deviceId)",
          "resolverDeviceId": "\(resolverDeviceId)",
          "version": "\(version)",
          "connection_timeout": \(connectionTimeout),
          "fingerprint": "\(fingerprint)",
          "lan_address": "\(lanAddress)",
          "pair_code": "\(pairCode)"
        }
        """
    }

    public static let sample = PairingPayload(
        deviceId: "ab128f3c",
        resolverDeviceId: "ab128f3c",
        version: "1.4",
        connectionTimeout: 300,
        fingerprint: "e7a9…2b41",
        lanAddress: "192.168.1.42:8080",
        pairCode: "849-204"
    )
}
