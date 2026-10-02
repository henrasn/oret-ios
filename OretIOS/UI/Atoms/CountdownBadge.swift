//
//  CountdownBadge.swift
//  OretIOS
//
//  Countdown chip displaying the active connect window duration
//  Conforms to Stitch Specification c11640a5ea8b4d56beb95ea6e1f2a248
//

import SwiftUI

public struct CountdownBadge: View {
    public let remainingSeconds: Int
    public var labelPrefix: String = "Connect window: "
    public var labelSuffix: String = " remaining"

    public init(
        remainingSeconds: Int,
        labelPrefix: String = "Connect window: ",
        labelSuffix: String = " remaining"
    ) {
        self.remainingSeconds = remainingSeconds
        self.labelPrefix = labelPrefix
        self.labelSuffix = labelSuffix
    }

    public var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "clock")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(AgedManuscriptTheme.Colors.amberWindowText)

            Text(formattedText)
                .font(AgedManuscriptTheme.Fonts.sansLabel(size: 13, weight: .medium))
                .foregroundColor(AgedManuscriptTheme.Colors.amberWindowText)
                .tracking(-0.2)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 6)
        .background(AgedManuscriptTheme.Colors.amberWindowBg)
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(AgedManuscriptTheme.Colors.amberWindowBorder, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.04), radius: 2, y: 1)
    }

    private var formattedText: String {
        if remainingSeconds <= 0 {
            return "Connect window: Expired"
        }
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        let timeString = String(format: "%02d:%02d", minutes, seconds)
        return "\(labelPrefix)\(timeString)\(labelSuffix)"
    }
}

#Preview("Countdown Active") {
    VStack(spacing: 16) {
        CountdownBadge(remainingSeconds: 272)
        CountdownBadge(remainingSeconds: 45)
        CountdownBadge(remainingSeconds: 0)
    }
    .padding()
    .agedManuscriptBackground()
}
