//
//  JsonPayloadBox.swift
//  OretIOS
//
//  Monospace Pairing JSON Payload Snippet Box with One-Tap Copy
//  Conforms to Stitch Specifications & user flow/device_connection_and_sync.md Section 4.1
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

public struct JsonPayloadBox: View {
    public let jsonContent: String
    @State private var hasCopied: Bool = false

    public init(jsonContent: String) {
        self.jsonContent = jsonContent
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header Bar: Title + Copy Button
            HStack {
                HStack(spacing: 5) {
                    Image(systemName: "curlybraces")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(AgedManuscriptTheme.Colors.inkSecondary)

                    Text("PAIRING PAYLOAD (JSON)")
                        .font(AgedManuscriptTheme.Fonts.sansLabel(size: 10, weight: .semibold))
                        .foregroundColor(AgedManuscriptTheme.Colors.inkSecondary)
                        .tracking(0.6)
                }

                Spacer()

                Button(action: copyToClipboard) {
                    HStack(spacing: 4) {
                        Image(systemName: hasCopied ? "checkmark" : "doc.on.doc")
                            .font(.system(size: 11, weight: .medium))

                        Text(hasCopied ? "Copied!" : "Copy")
                            .font(AgedManuscriptTheme.Fonts.sansLabel(size: 11, weight: .medium))
                    }
                    .foregroundColor(hasCopied ? AgedManuscriptTheme.Colors.statusGreen : AgedManuscriptTheme.Colors.inkPrimary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(hasCopied ? AgedManuscriptTheme.Colors.statusGreenBg : AgedManuscriptTheme.Colors.parchmentCard)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(hasCopied ? AgedManuscriptTheme.Colors.statusGreenBorder : AgedManuscriptTheme.Colors.parchmentBorder, lineWidth: 1)
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }

            // Code Content Box
            ScrollView(.horizontal, showsIndicators: false) {
                Text(jsonContent)
                    .font(AgedManuscriptTheme.Fonts.monoCode(size: 11, weight: .regular))
                    .foregroundColor(AgedManuscriptTheme.Colors.inkPrimary)
                    .multilineTextAlignment(.leading)
                    .lineSpacing(2)
                    .padding(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .background(Color(hex: "#FAF3E0"))
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(AgedManuscriptTheme.Colors.parchmentBorder.opacity(0.8), lineWidth: 1)
            )
        }
        .padding(12)
        .background(AgedManuscriptTheme.Colors.parchmentField)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(AgedManuscriptTheme.Colors.parchmentBorder, lineWidth: 1)
        )
    }

    private func copyToClipboard() {
        #if canImport(UIKit)
        UIPasteboard.general.string = jsonContent
        #endif
        hasCopied = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            hasCopied = false
        }
    }
}

#Preview("JSON Payload Box") {
    VStack(spacing: 16) {
        JsonPayloadBox(jsonContent: PairingPayload.sample.formattedJson())
    }
    .padding()
    .agedManuscriptBackground()
}
