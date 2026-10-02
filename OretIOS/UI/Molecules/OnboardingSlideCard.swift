//
//  OnboardingSlideCard.swift
//  OretIOS
//
//  Onboarding Slide Card Molecule with Tactile Aged Manuscript Illustrations
//

import SwiftUI

// MARK: - Slide 1: Local Storage Illustration
public struct LocalStorageIllustrationView: View {
    public init() {}

    public var body: some View {
        ZStack {
            // Warm pedestal shadow
            Ellipse()
                .fill(AgedManuscriptTheme.Colors.warmShadow)
                .frame(width: 250, height: 26)
                .offset(y: 90)

            // Open Archival Book / Journal
            ZStack {
                // Book Cover / Outer Spine
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(hex: "#2D2921"))
                    .frame(width: 254, height: 168)
                    .shadow(color: Color.black.opacity(0.12), radius: 6, y: 4)

                // Parchment Pages (Left Page)
                HStack(spacing: 0) {
                    ZStack(alignment: .topLeading) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(hex: "#FFFCF5"))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(AgedManuscriptTheme.Colors.parchmentBorder, lineWidth: 1)
                            )

                        // Ruled manuscript lines
                        VStack(alignment: .leading, spacing: 10) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(AgedManuscriptTheme.Colors.crimsonAccent.opacity(0.8))
                                .frame(width: 32, height: 4)
                                .padding(.top, 14)

                            ForEach(0..<6, id: \.self) { i in
                                RoundedRectangle(cornerRadius: 1)
                                    .fill(AgedManuscriptTheme.Colors.inkSecondary.opacity(0.3))
                                    .frame(width: CGFloat(75 - (i % 2) * 15), height: 2.5)
                            }
                        }
                        .padding(.leading, 14)
                    }
                    .frame(width: 118, height: 154)

                    // Book Gutter / Spine Divider
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(hex: "#DFD4BC").opacity(0.8),
                                    Color(hex: "#B8AA91"),
                                    Color(hex: "#DFD4BC").opacity(0.8)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: 10, height: 154)

                    // Parchment Pages (Right Page)
                    ZStack(alignment: .topLeading) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(hex: "#FFFCF5"))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(AgedManuscriptTheme.Colors.parchmentBorder, lineWidth: 1)
                            )

                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(AgedManuscriptTheme.Colors.inkDark.opacity(0.6))
                                    .frame(width: 44, height: 4)
                                Spacer()
                                Circle()
                                    .fill(AgedManuscriptTheme.Colors.oliveSage)
                                    .frame(width: 6, height: 6)
                            }
                            .padding(.top, 14)
                            .padding(.trailing, 14)

                            ForEach(0..<6, id: \.self) { i in
                                RoundedRectangle(cornerRadius: 1)
                                    .fill(AgedManuscriptTheme.Colors.inkSecondary.opacity(0.3))
                                    .frame(width: CGFloat(80 - (i % 3) * 12), height: 2.5)
                            }
                        }
                        .padding(.leading, 14)
                    }
                    .frame(width: 118, height: 154)
                }

                // Ribbon Bookmark drape
                Path { path in
                    path.move(to: CGPoint(x: 127, y: 6))
                    path.addLine(to: CGPoint(x: 127, y: 174))
                    path.addLine(to: CGPoint(x: 132, y: 168))
                    path.addLine(to: CGPoint(x: 137, y: 174))
                    path.addLine(to: CGPoint(x: 137, y: 6))
                }
                .fill(AgedManuscriptTheme.Colors.crimsonAccent)
                .frame(width: 254, height: 168)
            }
        }
        .frame(height: 220)
    }
}

// MARK: - Slide 2: Direct Sync Illustration
public struct DirectSyncIllustrationView: View {
    public init() {}

    public var body: some View {
        ZStack {
            // Warm pedestal shadow
            Ellipse()
                .fill(AgedManuscriptTheme.Colors.warmShadow)
                .frame(width: 280, height: 26)
                .offset(y: 90)

            // Connection waves between devices
            Path { path in
                path.move(to: CGPoint(x: 115, y: 100))
                path.addCurve(to: CGPoint(x: 200, y: 100), control1: CGPoint(x: 140, y: 80), control2: CGPoint(x: 175, y: 120))
            }
            .stroke(
                AgedManuscriptTheme.Colors.parchmentBorder,
                style: StrokeStyle(lineWidth: 2, lineCap: .round, dash: [4, 4])
            )

            Path { path in
                path.move(to: CGPoint(x: 115, y: 115))
                path.addCurve(to: CGPoint(x: 200, y: 115), control1: CGPoint(x: 140, y: 95), control2: CGPoint(x: 175, y: 135))
            }
            .stroke(
                AgedManuscriptTheme.Colors.parchmentBorder.opacity(0.7),
                style: StrokeStyle(lineWidth: 1.5, lineCap: .round, dash: [3, 3])
            )

            HStack(spacing: 28) {
                // Laptop (Left)
                VStack(spacing: 0) {
                    // Laptop Screen
                    ZStack {
                        RoundedRectangle(cornerRadius: 5)
                            .fill(Color(hex: "#383226"))
                            .frame(width: 86, height: 64)
                            .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(Color(hex: "#29241B"), lineWidth: 1.2)
                            )

                        // Inner Screen
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color(hex: "#FFFAEC"))
                            .frame(width: 76, height: 54)

                        // Manuscript Lines inside screen
                        VStack(alignment: .leading, spacing: 4) {
                            RoundedRectangle(cornerRadius: 1)
                                .fill(Color(hex: "#2D2921").opacity(0.8))
                                .frame(width: 28, height: 3)

                            RoundedRectangle(cornerRadius: 1)
                                .fill(AgedManuscriptTheme.Colors.inkSecondary.opacity(0.4))
                                .frame(width: 44, height: 2)

                            RoundedRectangle(cornerRadius: 1)
                                .fill(AgedManuscriptTheme.Colors.inkSecondary.opacity(0.4))
                                .frame(width: 38, height: 2)

                            // Mini note snippet
                            RoundedRectangle(cornerRadius: 2)
                                .fill(AgedManuscriptTheme.Colors.parchmentCard)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 2)
                                        .stroke(AgedManuscriptTheme.Colors.parchmentBorder, lineWidth: 0.8)
                                )
                                .frame(width: 26, height: 16)
                        }
                    }

                    // Keyboard Base
                    ZStack {
                        Path { path in
                            path.move(to: CGPoint(x: 0, y: 0))
                            path.addLine(to: CGPoint(x: 102, y: 0))
                            path.addLine(to: CGPoint(x: 95, y: 12))
                            path.addLine(to: CGPoint(x: 7, y: 12))
                            path.closeSubpath()
                        }
                        .fill(Color(hex: "#4A4233"))
                        .overlay(
                            Path { path in
                                path.move(to: CGPoint(x: 0, y: 0))
                                path.addLine(to: CGPoint(x: 102, y: 0))
                                path.addLine(to: CGPoint(x: 95, y: 12))
                                path.addLine(to: CGPoint(x: 7, y: 12))
                                path.closeSubpath()
                            }
                            .stroke(Color(hex: "#29241B"), lineWidth: 1)
                        )

                        // Trackpad
                        RoundedRectangle(cornerRadius: 1.5)
                            .fill(Color(hex: "#383226"))
                            .frame(width: 18, height: 5)
                            .offset(y: 3)
                    }
                    .frame(width: 102, height: 12)
                }

                // Phone (Right)
                ZStack {
                    // Phone body
                    RoundedRectangle(cornerRadius: 9)
                        .fill(Color(hex: "#383226"))
                        .frame(width: 50, height: 92)
                        .overlay(
                            RoundedRectangle(cornerRadius: 9)
                                .stroke(Color(hex: "#29241B"), lineWidth: 1.2)
                        )

                    // Phone screen
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(hex: "#FFFAEC"))
                        .frame(width: 42, height: 80)

                    // Speaker
                    RoundedRectangle(cornerRadius: 1)
                        .fill(Color(hex: "#756F61").opacity(0.6))
                        .frame(width: 12, height: 2)
                        .offset(y: -34)

                    // Synced note card on phone
                    VStack(alignment: .leading, spacing: 4) {
                        RoundedRectangle(cornerRadius: 1)
                            .fill(Color(hex: "#2D2921").opacity(0.8))
                            .frame(width: 18, height: 3)

                        RoundedRectangle(cornerRadius: 1)
                            .fill(AgedManuscriptTheme.Colors.inkSecondary.opacity(0.4))
                            .frame(width: 26, height: 2)

                        RoundedRectangle(cornerRadius: 2)
                            .fill(AgedManuscriptTheme.Colors.parchmentCard)
                            .overlay(
                                RoundedRectangle(cornerRadius: 2)
                                    .stroke(AgedManuscriptTheme.Colors.parchmentBorder, lineWidth: 0.8)
                            )
                            .frame(width: 30, height: 26)
                            .overlay(
                                VStack(alignment: .leading, spacing: 3) {
                                    RoundedRectangle(cornerRadius: 1)
                                        .fill(AgedManuscriptTheme.Colors.crimsonAccent.opacity(0.8))
                                        .frame(width: 14, height: 2)
                                    RoundedRectangle(cornerRadius: 1)
                                        .fill(AgedManuscriptTheme.Colors.inkSecondary.opacity(0.4))
                                        .frame(width: 20, height: 2)
                                }
                            )

                        // Secure sync indicator dot
                        HStack {
                            Spacer()
                            Circle()
                                .fill(AgedManuscriptTheme.Colors.oliveSage)
                                .frame(width: 5, height: 5)
                        }
                    }
                    .frame(width: 32)
                }
            }

            // Archival QR Matrix Seal in Center
            ZStack {
                Circle()
                    .fill(Color(hex: "#FFFCF5"))
                    .frame(width: 44, height: 44)
                    .overlay(
                        Circle().stroke(AgedManuscriptTheme.Colors.parchmentBorder, lineWidth: 1.2)
                    )

                Circle()
                    .stroke(
                        AgedManuscriptTheme.Colors.crimsonAccent,
                        style: StrokeStyle(lineWidth: 1.2, dash: [3, 2])
                    )
                    .frame(width: 38, height: 38)

                // Mini stylized matrix glyph
                Image(systemName: "qrcode")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(AgedManuscriptTheme.Colors.crimsonAccent)
            }
            .offset(y: -5)
        }
        .frame(height: 220)
    }
}

// MARK: - Slide 3: Intelligent Reconciliation Illustration
public struct ReconciliationIllustrationView: View {
    public init() {}

    public var body: some View {
        ZStack {
            // Warm pedestal shadow
            Ellipse()
                .fill(AgedManuscriptTheme.Colors.warmShadow)
                .frame(width: 280, height: 26)
                .offset(y: 95)

            // Archival Sheet Container
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(hex: "#FFFCF5"))
                    .frame(width: 260, height: 180)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(AgedManuscriptTheme.Colors.parchmentBorder, lineWidth: 1.4)
                    )
                    .shadow(color: Color.black.opacity(0.06), radius: 5, y: 3)

                VStack(spacing: 8) {
                    // Sheet Header Rule
                    HStack {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color(hex: "#2D2921").opacity(0.8))
                            .frame(width: 50, height: 4)
                        Spacer()
                        Circle().fill(Color(hex: "#D5CBAF")).frame(width: 5, height: 5)
                        Circle().fill(Color(hex: "#D5CBAF")).frame(width: 5, height: 5)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 10)

                    Divider()
                        .background(AgedManuscriptTheme.Colors.parchmentBorder)
                        .padding(.horizontal, 16)

                    // Two Diff Columns
                    HStack(spacing: 12) {
                        // Left Draft (Device A) with crimson diff
                        VStack(alignment: .leading, spacing: 4) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(AgedManuscriptTheme.Colors.inkMuted.opacity(0.6))
                                .frame(width: 24, height: 4)

                            RoundedRectangle(cornerRadius: 1)
                                .fill(AgedManuscriptTheme.Colors.inkSecondary.opacity(0.4))
                                .frame(width: 70, height: 2)

                            // Changed block A in terracotta
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color(hex: "#F5E8E4"))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 3)
                                        .stroke(Color(hex: "#DCB5AE"), style: StrokeStyle(lineWidth: 0.8, dash: [2, 2]))
                                )
                                .frame(width: 84, height: 16)
                                .overlay(
                                    VStack(alignment: .leading, spacing: 2) {
                                        RoundedRectangle(cornerRadius: 1)
                                            .fill(AgedManuscriptTheme.Colors.crimsonAccent)
                                            .frame(width: 44, height: 2)
                                        RoundedRectangle(cornerRadius: 1)
                                            .fill(AgedManuscriptTheme.Colors.crimsonAccent.opacity(0.7))
                                            .frame(width: 60, height: 2)
                                    }
                                    .padding(.leading, 4)
                                )

                            RoundedRectangle(cornerRadius: 1)
                                .fill(AgedManuscriptTheme.Colors.inkSecondary.opacity(0.3))
                                .frame(width: 55, height: 2)
                        }
                        .padding(6)
                        .frame(width: 100, height: 74)
                        .background(AgedManuscriptTheme.Colors.parchmentCard)
                        .cornerRadius(6)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(AgedManuscriptTheme.Colors.parchmentBorder, lineWidth: 0.8)
                        )

                        // Right Draft (Device B) with olive sage diff
                        VStack(alignment: .leading, spacing: 4) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(AgedManuscriptTheme.Colors.inkMuted.opacity(0.6))
                                .frame(width: 26, height: 4)

                            // Changed block B in sage
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color(hex: "#EBF0EA"))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 3)
                                        .stroke(Color(hex: "#B8CCB7"), style: StrokeStyle(lineWidth: 0.8, dash: [2, 2]))
                                )
                                .frame(width: 84, height: 16)
                                .overlay(
                                    VStack(alignment: .leading, spacing: 2) {
                                        RoundedRectangle(cornerRadius: 1)
                                            .fill(Color(hex: "#436348"))
                                            .frame(width: 48, height: 2)
                                        RoundedRectangle(cornerRadius: 1)
                                            .fill(Color(hex: "#436348").opacity(0.7))
                                            .frame(width: 36, height: 2)
                                    }
                                    .padding(.leading, 4)
                                )

                            RoundedRectangle(cornerRadius: 1)
                                .fill(AgedManuscriptTheme.Colors.inkSecondary.opacity(0.4))
                                .frame(width: 65, height: 2)

                            RoundedRectangle(cornerRadius: 1)
                                .fill(AgedManuscriptTheme.Colors.inkSecondary.opacity(0.3))
                                .frame(width: 48, height: 2)
                        }
                        .padding(6)
                        .frame(width: 100, height: 74)
                        .background(AgedManuscriptTheme.Colors.parchmentCard)
                        .cornerRadius(6)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(AgedManuscriptTheme.Colors.parchmentBorder, lineWidth: 0.8)
                        )
                    }

                    // Merged Result Strip
                    HStack(spacing: 8) {
                        RoundedRectangle(cornerRadius: 1)
                            .fill(Color(hex: "#436348"))
                            .frame(width: 38, height: 3)

                        RoundedRectangle(cornerRadius: 1)
                            .fill(AgedManuscriptTheme.Colors.crimsonAccent)
                            .frame(width: 44, height: 3)

                        RoundedRectangle(cornerRadius: 1)
                            .fill(AgedManuscriptTheme.Colors.inkSecondary.opacity(0.4))
                            .frame(width: 55, height: 2.5)
                    }
                    .frame(width: 216, height: 28)
                    .background(Color(hex: "#FDFAF3"))
                    .cornerRadius(5)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(AgedManuscriptTheme.Colors.parchmentBorder, lineWidth: 1)
                    )
                    .padding(.bottom, 6)
                }
            }

            // Central Archival Wax Stamp / Verification Seal with Checkmark
            ZStack {
                Circle()
                    .fill(Color(hex: "#2D2921").opacity(0.15))
                    .frame(width: 44, height: 44)
                    .offset(y: 2)

                Circle()
                    .fill(Color(hex: "#FDFCF7"))
                    .frame(width: 42, height: 42)
                    .overlay(
                        Circle().stroke(AgedManuscriptTheme.Colors.parchmentBorder, lineWidth: 1.2)
                    )

                Circle()
                    .fill(Color(hex: "#2D2921"))
                    .frame(width: 36, height: 36)

                Circle()
                    .stroke(
                        AgedManuscriptTheme.Colors.parchmentBorder,
                        style: StrokeStyle(lineWidth: 0.8, dash: [2.5, 2])
                    )
                    .frame(width: 30, height: 30)

                Image(systemName: "checkmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(AgedManuscriptTheme.Colors.parchment)
            }
            .offset(y: 8)
        }
        .frame(height: 220)
    }
}

// MARK: - OnboardingSlideCard Molecule
public struct OnboardingSlideCard: View {
    public let slide: OnboardingSlide

    public init(slide: OnboardingSlide) {
        self.slide = slide
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Tactile Hero Illustration
            Group {
                switch slide.illustrationType {
                case .localStorage:
                    LocalStorageIllustrationView()
                case .directSync:
                    DirectSyncIllustrationView()
                case .intelligentReconciliation:
                    ReconciliationIllustrationView()
                }
            }
            .padding(.bottom, 24)

            // Title & Subtitle Copy
            VStack(spacing: 12) {
                Text(slide.title)
                    .font(AgedManuscriptTheme.Fonts.serifTitle(size: 24, weight: .semibold))
                    .foregroundColor(AgedManuscriptTheme.Colors.inkPrimary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)

                Text(slide.description)
                    .font(AgedManuscriptTheme.Fonts.sansBody(size: 15, weight: .regular))
                    .foregroundColor(AgedManuscriptTheme.Colors.inkSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .frame(maxWidth: 330)
            }
            .padding(.horizontal, 16)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    VStack(spacing: 40) {
        OnboardingSlideCard(slide: OnboardingSlide.canonicalSlides[0])
    }
    .padding()
    .agedManuscriptBackground()
}
