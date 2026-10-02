//
//  PairingActionRow.swift
//  OretIOS
//
//  Primary & Secondary Pairing Action Buttons (Aged Manuscript theme)
//  Conforms to Stitch Specification 1222f321421342328b0c91c2ab942de3
//

import SwiftUI

public struct PairingActionRow: View {
    public let onScanQR: () -> Void
    public let onShowQR: () -> Void

    public init(
        onScanQR: @escaping () -> Void,
        onShowQR: @escaping () -> Void
    ) {
        self.onScanQR = onScanQR
        self.onShowQR = onShowQR
    }

    public var body: some View {
        VStack(spacing: 12) {
            // 1. Primary Action: Scan QR Code
            Button(action: onScanQR) {
                HStack(spacing: 10) {
                    Image(systemName: "camera.viewfinder")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)

                    Text("Scan QR Code")
                        .font(AgedManuscriptTheme.Fonts.sansBody(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(AgedManuscriptTheme.Colors.inkDark)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .shadow(color: Color.black.opacity(0.12), radius: 4, y: 2)
            }
            .buttonStyle(PressableActionButtonStyle())

            // 2. Secondary Action: Show My QR Code
            Button(action: onShowQR) {
                HStack(spacing: 10) {
                    Image(systemName: "qrcode")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(AgedManuscriptTheme.Colors.inkPrimary)

                    Text("Show My QR Code")
                        .font(AgedManuscriptTheme.Fonts.sansBody(size: 15, weight: .medium))
                        .foregroundColor(AgedManuscriptTheme.Colors.inkPrimary)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(AgedManuscriptTheme.Colors.parchmentField)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(AgedManuscriptTheme.Colors.parchmentBorder, lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.03), radius: 2, y: 1)
            }
            .buttonStyle(PressableActionButtonStyle())
        }
    }
}

// MARK: - Pressable Button Style Helper
private struct PressableActionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.985 : 1.0)
            .opacity(configuration.isPressed ? 0.92 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

#Preview("Pairing Action Buttons") {
    VStack(spacing: 16) {
        PairingActionRow(
            onScanQR: {},
            onShowQR: {}
        )
    }
    .padding()
    .agedManuscriptBackground()
}
