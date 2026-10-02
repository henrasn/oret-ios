import SwiftUI

public struct ConflictKindBadge: View {
    public let kind: ConflictKind
    
    public init(kind: ConflictKind) {
        self.kind = kind
    }
    
    public var body: some View {
        Text(kind.label)
            .font(.system(size: 11, weight: .bold))
            .foregroundColor(textColor)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(backgroundColor)
            .overlay(
                Capsule()
                    .stroke(borderColor, lineWidth: 1)
            )
            .clipShape(Capsule())
    }
    
    private var backgroundColor: Color {
        switch kind {
        case .content:
            return AgedManuscriptTheme.Colors.errorContainer
        case .move:
            return AgedManuscriptTheme.Colors.amberWindowBg
        case .deleteVsEdit:
            return AgedManuscriptTheme.Colors.parchmentField
        }
    }
    
    private var textColor: Color {
        switch kind {
        case .content:
            return AgedManuscriptTheme.Colors.errorRed
        case .move:
            return AgedManuscriptTheme.Colors.amberWindowText
        case .deleteVsEdit:
            return AgedManuscriptTheme.Colors.inkSecondary
        }
    }
    
    private var borderColor: Color {
        switch kind {
        case .content:
            return AgedManuscriptTheme.Colors.errorContainer
        case .move:
            return AgedManuscriptTheme.Colors.amberWindowBorder
        case .deleteVsEdit:
            return AgedManuscriptTheme.Colors.parchmentBorder
        }
    }
}

#Preview {
    VStack(spacing: 8) {
        ConflictKindBadge(kind: .content)
        ConflictKindBadge(kind: .move)
        ConflictKindBadge(kind: .deleteVsEdit)
    }
    .padding()
    .background(AgedManuscriptTheme.Colors.parchment)
}
