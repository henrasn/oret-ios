//
//  QrCodeVectorView.swift
//  OretIOS
//
//  High-Contrast Crisp Vector QR Code Matrix with Archival Center Seal Badge
//  Conforms to Stitch Specification c11640a5ea8b4d56beb95ea6e1f2a248
//

import SwiftUI

public struct QrCodeVectorView: View {
    public var size: CGFloat = 220
    public var payloadString: String? = nil

    public init(size: CGFloat = 220, payloadString: String? = nil) {
        self.size = size
        self.payloadString = payloadString
    }

    public var body: some View {
        ZStack {
            // White Container Card with aged border
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .frame(width: size + 32, height: size + 32)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(AgedManuscriptTheme.Colors.parchmentBorder, lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.04), radius: 3, y: 1)

            // Vector QR Code Matrix
            qrMatrixContent
                .frame(width: size, height: size)
        }
    }

    private var qrMatrixContent: some View {
        GeometryReader { geometry in
            let scale = geometry.size.width / 160.0

            ZStack {
                // Background
                Color.white

                // Finder Patterns & Timing & Data Modules
                Canvas { context, _ in
                    let inkColor = AgedManuscriptTheme.Colors.inkDark

                    // Helper to draw module rectangle in 160x160 space scaled
                    func fillRect(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) {
                        let rect = CGRect(
                            x: x * scale,
                            y: y * scale,
                            width: width * scale,
                            height: height * scale
                        )
                        context.fill(Path(rect), with: .color(inkColor))
                    }

                    // 1. Finder Pattern Top-Left (10, 10)
                    drawFinderPattern(at: CGPoint(x: 10, y: 10), scale: scale, in: &context, color: inkColor)

                    // 2. Finder Pattern Top-Right (115, 10)
                    drawFinderPattern(at: CGPoint(x: 115, y: 10), scale: scale, in: &context, color: inkColor)

                    // 3. Finder Pattern Bottom-Left (10, 115)
                    drawFinderPattern(at: CGPoint(x: 10, y: 115), scale: scale, in: &context, color: inkColor)

                    // 4. Horizontal Timing Patterns (y=40, from x=50 to 110)
                    for x in stride(from: 50.0, through: 100.0, by: 10.0) {
                        fillRect(x: CGFloat(x), y: 40, width: 5, height: 5)
                    }

                    // 5. Vertical Timing Patterns (x=40, from y=50 to 110)
                    for y in stride(from: 50.0, through: 100.0, by: 10.0) {
                        fillRect(x: 40, y: CGFloat(y), width: 5, height: 5)
                    }

                    // 6. Alignment Pattern (100, 100)
                    drawAlignmentPattern(at: CGPoint(x: 100, y: 100), scale: scale, in: &context, color: inkColor)

                    // 7. Data Modules matching Stitch Vector Matrix
                    let modules: [(CGFloat, CGFloat, CGFloat, CGFloat)] = [
                        // Top Region between TL and TR
                        (50, 15, 10, 5), (65, 10, 5, 10), (75, 15, 10, 5),
                        (90, 10, 5, 15), (100, 20, 10, 5), (55, 25, 5, 10),
                        (70, 25, 10, 10), (85, 30, 15, 5),

                        // Center Upper Body
                        (50, 50, 15, 5), (70, 50, 5, 10), (85, 50, 10, 5),
                        (100, 50, 15, 5), (120, 50, 10, 10), (135, 55, 15, 5),
                        (15, 55, 10, 5), (30, 50, 5, 15), (10, 65, 15, 5), (30, 70, 10, 5),

                        // Mid Horizontal Bands
                        (50, 60, 10, 10), (65, 65, 15, 5), (85, 60, 5, 15),
                        (95, 65, 10, 10), (115, 65, 15, 5), (135, 65, 10, 10),
                        (15, 80, 5, 10), (25, 85, 15, 5), (10, 95, 10, 10), (25, 100, 10, 5),

                        // Center Lower Body
                        (50, 75, 15, 5), (70, 75, 10, 10), (85, 80, 15, 5),
                        (105, 75, 5, 15), (120, 80, 10, 5), (135, 80, 5, 15), (145, 85, 10, 5),
                        (50, 90, 10, 10), (65, 90, 5, 15), (75, 95, 15, 5),
                        (95, 90, 10, 10), (115, 90, 10, 5), (130, 95, 15, 10),

                        // Lower Region / Bottom Right
                        (50, 105, 15, 5), (70, 110, 10, 10), (85, 105, 10, 5),
                        (55, 120, 5, 15), (65, 125, 15, 5), (70, 135, 10, 10),
                        (85, 120, 15, 10), (85, 135, 10, 10), (130, 110, 10, 15),
                        (145, 115, 10, 5), (105, 130, 15, 5), (125, 130, 10, 10),
                        (140, 130, 15, 5), (105, 140, 10, 10), (120, 145, 15, 5),
                        (140, 140, 10, 10)
                    ]

                    for m in modules {
                        fillRect(x: m.0, y: m.1, width: m.2, height: m.3)
                    }
                }

                // Archival Center Seal Badge in QR Core
                centerSealBadge(scale: scale)
            }
        }
    }

    private func drawFinderPattern(
        at origin: CGPoint,
        scale: CGFloat,
        in context: inout GraphicsContext,
        color: Color
    ) {
        // Outer box 35x35
        let outerRect = CGRect(x: origin.x * scale, y: origin.y * scale, width: 35 * scale, height: 35 * scale)
        // Inner white clearance 25x25 (stroke width 5)
        let innerRect = CGRect(x: (origin.x + 5) * scale, y: (origin.y + 5) * scale, width: 25 * scale, height: 25 * scale)
        // Center solid box 15x15
        let centerRect = CGRect(x: (origin.x + 10) * scale, y: (origin.y + 10) * scale, width: 15 * scale, height: 15 * scale)

        var outerPath = Path(outerRect)
        outerPath.addPath(Path(innerRect))
        context.fill(outerPath, with: .color(color), style: FillStyle(eoFill: true))

        context.fill(Path(centerRect), with: .color(color))
    }

    private func drawAlignmentPattern(
        at origin: CGPoint,
        scale: CGFloat,
        in context: inout GraphicsContext,
        color: Color
    ) {
        let outerRect = CGRect(x: origin.x * scale, y: origin.y * scale, width: 25 * scale, height: 25 * scale)
        let innerRect = CGRect(x: (origin.x + 5) * scale, y: (origin.y + 5) * scale, width: 15 * scale, height: 15 * scale)
        let centerRect = CGRect(x: (origin.x + 10) * scale, y: (origin.y + 10) * scale, width: 5 * scale, height: 5 * scale)

        var outerPath = Path(outerRect)
        outerPath.addPath(Path(innerRect))
        context.fill(outerPath, with: .color(color), style: FillStyle(eoFill: true))

        context.fill(Path(centerRect), with: .color(color))
    }

    private func centerSealBadge(scale: CGFloat) -> some View {
        let badgeSize = 28 * scale
        return ZStack {
            RoundedRectangle(cornerRadius: 5 * scale)
                .fill(Color.white)
                .frame(width: badgeSize, height: badgeSize)
                .overlay(
                    RoundedRectangle(cornerRadius: 5 * scale)
                        .stroke(AgedManuscriptTheme.Colors.parchmentBorder, lineWidth: 1.5 * scale)
                )

            // Terracotta / Wax Seal Padlock Emblem
            Image(systemName: "lock.fill")
                .font(.system(size: 13 * scale, weight: .bold))
                .foregroundColor(AgedManuscriptTheme.Colors.crimsonAccent)
        }
        .position(x: 80 * scale, y: 80 * scale)
    }
}

#Preview("Vector QR Code Preview") {
    VStack(spacing: 24) {
        QrCodeVectorView(size: 220)
    }
    .padding()
    .agedManuscriptBackground()
}
