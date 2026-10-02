//
//  ReviewChooserSegment.swift
//  OretIOS
//
//  Upfront Chooser Segment for Conflict Reviewer Role
//  Conforms to Stitch Specifications & user flow/device_connection_and_sync.md Section 4.1
//

import SwiftUI

public struct ReviewChooserSegment: View {
    @Binding public var selectedRole: ResolverRole
    @Binding public var rememberPreference: Bool
    public var isLocked: Bool = false

    public init(
        selectedRole: Binding<ResolverRole>,
        rememberPreference: Binding<Bool> = .constant(true),
        isLocked: Bool = false
    ) {
        self._selectedRole = selectedRole
        self._rememberPreference = rememberPreference
        self.isLocked = isLocked
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Header with title and lock/hint indicator
            HStack(alignment: .firstTextBaseline) {
                Text("Review & Resolve Changes On:")
                    .font(AgedManuscriptTheme.Fonts.sansLabel(size: 13, weight: .semibold))
                    .foregroundColor(AgedManuscriptTheme.Colors.inkPrimary)

                Spacer()

                if isLocked {
                    HStack(spacing: 4) {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 10))
                        Text("Locked by peer")
                            .font(AgedManuscriptTheme.Fonts.sansLabel(size: 11, weight: .medium))
                    }
                    .foregroundColor(AgedManuscriptTheme.Colors.inkMuted)
                } else {
                    Text("Select before scan")
                        .font(AgedManuscriptTheme.Fonts.sansLabel(size: 11, weight: .regular))
                        .foregroundColor(AgedManuscriptTheme.Colors.inkSecondary)
                }
            }

            // Segmented selection buttons
            HStack(spacing: 8) {
                ForEach(ResolverRole.allCases) { role in
                    roleOptionButton(role: role)
                }
            }

            // Remember preference checkbox row
            Button(action: {
                if !isLocked {
                    rememberPreference.toggle()
                }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: rememberPreference ? "checkmark.square.fill" : "square")
                        .font(.system(size: 14))
                        .foregroundColor(rememberPreference ? AgedManuscriptTheme.Colors.inkDark : AgedManuscriptTheme.Colors.inkMuted)

                    Text("Remember review preference for this workspace")
                        .font(AgedManuscriptTheme.Fonts.sansLabel(size: 11, weight: .regular))
                        .foregroundColor(AgedManuscriptTheme.Colors.inkSecondary)
                }
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(isLocked)
            .padding(.top, 2)
        }
        .padding(12)
        .background(AgedManuscriptTheme.Colors.parchmentField)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(AgedManuscriptTheme.Colors.parchmentBorder, lineWidth: 1)
        )
    }

    @ViewBuilder
    private func roleOptionButton(role: ResolverRole) -> some View {
        let isSelected = selectedRole == role

        Button(action: {
            if !isLocked {
                selectedRole = role
            }
        }) {
            HStack(spacing: 6) {
                Image(systemName: role.iconName)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(isSelected ? AgedManuscriptTheme.Colors.inkDark : AgedManuscriptTheme.Colors.inkSecondary)

                VStack(alignment: .leading, spacing: 1) {
                    Text(role.title)
                        .font(AgedManuscriptTheme.Fonts.sansLabel(size: 12, weight: isSelected ? .semibold : .medium))
                        .foregroundColor(isSelected ? AgedManuscriptTheme.Colors.inkDark : AgedManuscriptTheme.Colors.inkSecondary)
                        .lineLimit(1)

                    Text(role.subtitle)
                        .font(.system(size: 9, weight: .regular))
                        .foregroundColor(isSelected ? AgedManuscriptTheme.Colors.inkSecondary : AgedManuscriptTheme.Colors.inkMuted)
                        .lineLimit(1)
                }

                Spacer(minLength: 0)

                if isSelected {
                    Circle()
                        .fill(AgedManuscriptTheme.Colors.inkDark)
                        .frame(width: 6, height: 6)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .background(isSelected ? AgedManuscriptTheme.Colors.parchmentCard : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? AgedManuscriptTheme.Colors.inkDark.opacity(0.3) : AgedManuscriptTheme.Colors.parchmentBorder.opacity(0.8), lineWidth: 1)
            )
            .shadow(color: isSelected ? Color.black.opacity(0.04) : Color.clear, radius: 2, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isLocked)
    }
}

#Preview("Review Chooser Options") {
    VStack(spacing: 16) {
        ReviewChooserSegment(
            selectedRole: .constant(.thisDevice),
            rememberPreference: .constant(true),
            isLocked: false
        )

        ReviewChooserSegment(
            selectedRole: .constant(.otherDevice),
            rememberPreference: .constant(false),
            isLocked: true
        )
    }
    .padding()
    .agedManuscriptBackground()
}
