//
//  DeviceIdentityView.swift
//  OretIOS
//
//  Device Identity Card Molecule (Aged Manuscript theme)
//  Conforms to Stitch Specification 1222f321421342328b0c91c2ab942de3
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

public struct DeviceIdentityView: View {
    public let deviceInfo: LocalDeviceInfo
    @State private var hasCopiedFingerprint: Bool = false

    public init(deviceInfo: LocalDeviceInfo = .sample) {
        self.deviceInfo = deviceInfo
    }

    public var body: some View {
        VStack(spacing: 14) {
            // Top Row: Device Icon + Titles
            HStack(spacing: 12) {
                // Device Icon Container
                ZStack {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(hex: "#EFE8D5"))
                        .frame(width: 40, height: 40)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color(hex: "#E0D3B5"), lineWidth: 1)
                        )

                    Image(systemName: "iphone")
                        .font(.system(size: 20, weight: .regular))
                        .foregroundColor(AgedManuscriptTheme.Colors.inkDark)
                }

                // Device Name & Role
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 4) {
                        Text(deviceInfo.deviceName)
                            .font(AgedManuscriptTheme.Fonts.serifTitle(size: 16, weight: .semibold))
                            .foregroundColor(AgedManuscriptTheme.Colors.inkPrimary)

                        Text("(This Device)")
                            .font(AgedManuscriptTheme.Fonts.sansBody(size: 13, weight: .regular))
                            .foregroundColor(AgedManuscriptTheme.Colors.inkSecondary)
                    }

                    Text(deviceInfo.roleCaption.uppercased())
                        .font(AgedManuscriptTheme.Fonts.sansLabel(size: 10, weight: .medium))
                        .foregroundColor(AgedManuscriptTheme.Colors.inkSecondary)
                        .tracking(0.8)
                }

                Spacer()
            }

            // Divider Line
            Rectangle()
                .fill(AgedManuscriptTheme.Colors.parchmentBorder.opacity(0.7))
                .frame(height: 1)

            // Bottom Row: Fingerprint Label & Monospace Chip
            HStack {
                Text("Device Fingerprint")
                    .font(AgedManuscriptTheme.Fonts.sansLabel(size: 11, weight: .medium))
                    .foregroundColor(AgedManuscriptTheme.Colors.inkSecondary)

                Spacer()

                Button(action: copyFingerprint) {
                    HStack(spacing: 4) {
                        if hasCopiedFingerprint {
                            Image(systemName: "checkmark")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(AgedManuscriptTheme.Colors.statusGreen)
                        }

                        Text("ID: \(deviceInfo.fingerprint)")
                            .font(AgedManuscriptTheme.Fonts.monoCode(size: 12, weight: .regular))
                            .foregroundColor(AgedManuscriptTheme.Colors.inkSecondary)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color(hex: "#EFE8D5"))
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color(hex: "#E2D5B7"), lineWidth: 1)
                    )
                }
                .buttonStyle(PlainButtonStyle())
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

    private func copyFingerprint() {
        #if canImport(UIKit)
        UIPasteboard.general.string = deviceInfo.fingerprint
        #endif
        hasCopiedFingerprint = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            hasCopiedFingerprint = false
        }
    }
}

#Preview("Device Identity Card") {
    VStack(spacing: 16) {
        DeviceIdentityView(deviceInfo: .sample)
    }
    .padding()
    .agedManuscriptBackground()
}
