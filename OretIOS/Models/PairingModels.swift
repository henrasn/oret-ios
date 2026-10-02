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

// MARK: - Payload Validation Errors
public enum PayloadValidationError: LocalizedError, Equatable {
    case emptyPayload
    case invalidJson(reason: String)
    case missingRequiredField(fieldName: String)
    case invalidProtocolVersion(version: String)
    case expired(secondsPast: Int)

    public var errorDescription: String? {
        switch self {
        case .emptyPayload:
            return "Pairing payload is empty. Please enter or paste valid JSON."
        case .invalidJson(let reason):
            return "Malformed pairing JSON payload: \(reason)"
        case .missingRequiredField(let fieldName):
            return "Missing mandatory pairing field '\(fieldName)'."
        case .invalidProtocolVersion(let version):
            return "Unsupported pairing protocol version '\(version)'."
        case .expired(let seconds):
            return "Pairing payload connection window has expired (\(seconds)s ago)."
        }
    }
}

// MARK: - Pairing Payload Model
public struct PairingPayload: Codable, Equatable {
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

    public func toKmpModel() -> PairingPayloadModel {
        return PairingPayloadModel(
            deviceId: deviceId,
            resolverDeviceId: resolverDeviceId,
            version: version,
            connectionTimeout: Int32(connectionTimeout),
            fingerprint: fingerprint,
            lanAddress: lanAddress,
            pairCode: pairCode
        )
    }
    #endif

    // MARK: - Codable Conformance with Flexible Snake/Camel Case Keys

    enum CodingKeys: String, CodingKey {
        case deviceId = "device_id"
        case deviceIdAlt = "deviceId"
        case resolverDeviceId = "resolverDeviceId"
        case resolverDeviceIdSnake = "resolver_device_id"
        case version
        case connectionTimeout = "connection_timeout"
        case connectionTimeoutAlt = "connectionTimeout"
        case fingerprint
        case certFingerprint = "cert_fingerprint"
        case lanAddress = "lan_address"
        case address
        case lanAddressAlt = "lanAddress"
        case pairCode = "pair_code"
        case pairCodeAlt = "pairCode"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // 1. device_id / deviceId
        if let dId = try? container.decode(String.self, forKey: .deviceId) {
            self.deviceId = dId
        } else if let dId = try? container.decode(String.self, forKey: .deviceIdAlt) {
            self.deviceId = dId
        } else {
            throw PayloadValidationError.missingRequiredField(fieldName: "device_id")
        }

        // 2. resolverDeviceId / resolver_device_id (MANDATORY contract)
        if let rId = try? container.decode(String.self, forKey: .resolverDeviceId) {
            self.resolverDeviceId = rId
        } else if let rId = try? container.decode(String.self, forKey: .resolverDeviceIdSnake) {
            self.resolverDeviceId = rId
        } else {
            throw PayloadValidationError.missingRequiredField(fieldName: "resolverDeviceId")
        }

        // 3. version (String or Int)
        if let vStr = try? container.decode(String.self, forKey: .version) {
            self.version = vStr
        } else if let vInt = try? container.decode(Int.self, forKey: .version) {
            self.version = String(vInt)
        } else {
            throw PayloadValidationError.missingRequiredField(fieldName: "version")
        }

        // 4. connection_timeout / connectionTimeout (Int or String)
        if let timeout = try? container.decode(Int.self, forKey: .connectionTimeout) {
            self.connectionTimeout = timeout
        } else if let timeout = try? container.decode(Int.self, forKey: .connectionTimeoutAlt) {
            self.connectionTimeout = timeout
        } else if let timeoutStr = try? container.decode(String.self, forKey: .connectionTimeout), let timeout = Int(timeoutStr) {
            self.connectionTimeout = timeout
        } else {
            throw PayloadValidationError.missingRequiredField(fieldName: "connection_timeout")
        }

        // 5. fingerprint / cert_fingerprint
        if let fp = try? container.decode(String.self, forKey: .fingerprint) {
            self.fingerprint = fp
        } else if let fp = try? container.decode(String.self, forKey: .certFingerprint) {
            self.fingerprint = fp
        } else {
            throw PayloadValidationError.missingRequiredField(fieldName: "fingerprint")
        }

        // 6. lan_address / address / lanAddress (optional fallback)
        if let addr = try? container.decode(String.self, forKey: .lanAddress) {
            self.lanAddress = addr
        } else if let addr = try? container.decode(String.self, forKey: .address) {
            self.lanAddress = addr
        } else if let addr = try? container.decode(String.self, forKey: .lanAddressAlt) {
            self.lanAddress = addr
        } else {
            self.lanAddress = "127.0.0.1:8443"
        }

        // 7. pair_code / pairCode (optional fallback)
        if let pc = try? container.decode(String.self, forKey: .pairCode) {
            self.pairCode = pc
        } else if let pc = try? container.decode(String.self, forKey: .pairCodeAlt) {
            self.pairCode = pc
        } else {
            self.pairCode = "000-000"
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(deviceId, forKey: .deviceId)
        try container.encode(resolverDeviceId, forKey: .resolverDeviceId)
        try container.encode(version, forKey: .version)
        try container.encode(connectionTimeout, forKey: .connectionTimeout)
        try container.encode(fingerprint, forKey: .fingerprint)
        try container.encode(lanAddress, forKey: .lanAddress)
        try container.encode(pairCode, forKey: .pairCode)
    }

    // MARK: - Validation & Parsing Logic

    /// Validates mandatory fields according to Stitch Spec & API docs
    public func validate() throws {
        let cleanDevId = deviceId.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanDevId.isEmpty else {
            throw PayloadValidationError.missingRequiredField(fieldName: "device_id")
        }
        let cleanResId = resolverDeviceId.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanResId.isEmpty else {
            throw PayloadValidationError.missingRequiredField(fieldName: "resolverDeviceId")
        }
        let cleanVer = version.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanVer.isEmpty else {
            throw PayloadValidationError.missingRequiredField(fieldName: "version")
        }
        guard connectionTimeout > 0 else {
            throw PayloadValidationError.missingRequiredField(fieldName: "connection_timeout")
        }
        let cleanFp = fingerprint.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanFp.isEmpty else {
            throw PayloadValidationError.missingRequiredField(fieldName: "fingerprint")
        }
    }

    /// Parses and strictly validates a raw JSON string
    public static func parseAndValidate(jsonString: String) throws -> PairingPayload {
        let trimmed = jsonString.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw PayloadValidationError.emptyPayload
        }

        guard let data = trimmed.data(using: .utf8) else {
            throw PayloadValidationError.invalidJson(reason: "Cannot encode input into UTF-8")
        }

        do {
            let decoded = try JSONDecoder().decode(PairingPayload.self, from: data)
            try decoded.validate()
            return decoded
        } catch let err as PayloadValidationError {
            throw err
        } catch {
            throw PayloadValidationError.invalidJson(reason: error.localizedDescription)
        }
    }

    /// Factory method to generate a host pairing payload with an explicitly designated resolverDeviceId
    public static func generateHostPayload(
        deviceId: String,
        resolverDeviceId: String,
        version: String = "1.4",
        connectionTimeout: Int = 300,
        fingerprint: String = "e7a9…2b41",
        lanAddress: String = "192.168.1.42:8080",
        pairCode: String = "849-204"
    ) -> PairingPayload {
        return PairingPayload(
            deviceId: deviceId,
            resolverDeviceId: resolverDeviceId,
            version: version,
            connectionTimeout: connectionTimeout,
            fingerprint: fingerprint,
            lanAddress: lanAddress,
            pairCode: pairCode
        )
    }

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
