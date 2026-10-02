//
//  ReadOnlyLockBanner.swift
//  OretIOS
//
//  Molecule: Read-Only Workspace Write-Lock Banner
//  Conforms to Stitch Specifications ae23723aa9504ea0be94db06980a1bd8 & eae64b528e4840079112c883651218e1
//  and device_connection_and_sync.md Section 5.1
//

import SwiftUI

public struct ReadOnlyLockBanner: View {
    public let peerName: String?
    public let isResolver: Bool
    public var onDetailsTapped: (() -> Void)?

    public init(
        peerName: String? = nil,
        isResolver: Bool = false,
        onDetailsTapped: (() -> Void)? = nil
    ) {
        self.peerName = peerName
        self.isResolver = isResolver
        self.onDetailsTapped = onDetailsTapped
    }

    public var body: some View {
        HStack(alignment: .center, spacing: 12) {
            // Leading Lock Seal Icon
            ZStack {
                Circle()
                    .fill(Color(hex: "#FAF3E0"))
                    .frame(width: 32, height: 32)
                    .overlay(
                        Circle().stroke(AgedManuscriptTheme.Colors.parchmentBorder, lineWidth: 1)
                    )

                Image(systemName: "lock.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AgedManuscriptTheme.Colors.folderAmber)
            }

            // Message text
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text("Workspace Locked — Sync in Progress")
                        .font(AgedManuscriptTheme.Fonts.sansLabel(size: 13, weight: .semibold))
                        .foregroundColor(AgedManuscriptTheme.Colors.inkPrimary)

                    // Spinning sync indicator dot
                    Circle()
                        .fill(AgedManuscriptTheme.Colors.folderAmber)
                        .frame(width: 6, height: 6)
                }

                if let peer = peerName {
                    Text("Synchronizing with '\(peer)'. Editing and mutations are temporarily disabled.")
                        .font(AgedManuscriptTheme.Fonts.sansLabel(size: 11.5, weight: .regular))
                        .foregroundColor(AgedManuscriptTheme.Colors.inkSecondary)
                        .lineLimit(2)
                } else {
                    Text("Editing is temporarily disabled to prevent conflicting modifications while files are synchronized.")
                        .font(AgedManuscriptTheme.Fonts.sansLabel(size: 11.5, weight: .regular))
                        .foregroundColor(AgedManuscriptTheme.Colors.inkSecondary)
                        .lineLimit(2)
                }
            }

            Spacer()

            // Trailing Read-Only Pill Badge
            HStack(spacing: 4) {
                Image(systemName: "lock")
                    .font(.system(size: 10, weight: .bold))

                Text("Read-Only")
                    .font(AgedManuscriptTheme.Fonts.sansLabel(size: 11, weight: .semibold))
            }
            .foregroundColor(AgedManuscriptTheme.Colors.inkPrimary)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color(hex: "#EFE8D5"))
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(AgedManuscriptTheme.Colors.parchmentBorder, lineWidth: 1)
            )
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(AgedManuscriptTheme.Colors.parchmentField)
        .overlay(
            Rectangle()
                .fill(AgedManuscriptTheme.Colors.parchmentBorder)
                .frame(height: 1),
            alignment: .bottom
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text("Workspace Locked — Sync in progress, Read-Only mode active"))
    }
}

// MARK: - SwiftUI #Previews

#Preview("Read-Only Lock Banner - Default") {
    VStack {
        ReadOnlyLockBanner()
        Spacer()
    }
    .agedManuscriptBackground()
}

#Preview("Read-Only Lock Banner - Peer Active") {
    VStack {
        ReadOnlyLockBanner(peerName: "MacBook Air", isResolver: false)
        Spacer()
    }
    .agedManuscriptBackground()
}
