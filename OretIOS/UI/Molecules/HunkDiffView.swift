import SwiftUI

public struct HunkDiffView: View {
    public let hunk: ConflictHunk
    public let localDeviceName: String
    public let peerDeviceName: String
    public let onPickLocal: () -> Void
    public let onPickPeer: () -> Void
    public let onPickBoth: () -> Void
    
    public init(
        hunk: ConflictHunk,
        localDeviceName: String,
        peerDeviceName: String,
        onPickLocal: @escaping () -> Void,
        onPickPeer: @escaping () -> Void,
        onPickBoth: @escaping () -> Void
    ) {
        self.hunk = hunk
        self.localDeviceName = localDeviceName
        self.peerDeviceName = peerDeviceName
        self.onPickLocal = onPickLocal
        self.onPickPeer = onPickPeer
        self.onPickBoth = onPickBoth
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(hunk.title)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(AgedManuscriptTheme.Colors.inkDark)
                    Text(hunk.lineRange)
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(AgedManuscriptTheme.Colors.inkSecondary)
                }
                Spacer()
                if let choice = hunk.resolvedChoice {
                    Text("Choice: \(choice)")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(AgedManuscriptTheme.Colors.statusGreen)
                }
            }
            
            // Local lines
            VStack(alignment: .leading, spacing: 4) {
                Text("Local (\(localDeviceName)):")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(AgedManuscriptTheme.Colors.inkSecondary)
                
                ForEach(hunk.localLines) { line in
                    HStack {
                        Text(line.isDeletion ? "- \(line.text)" : "  \(line.text)")
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(line.isDeletion ? Color(hex: "#991B1B") : AgedManuscriptTheme.Colors.inkDark)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(line.isDeletion ? Color(hex: "#FDE8E8") : Color(hex: "#FAF5E8"))
                            .cornerRadius(4)
                    }
                }
            }
            
            // Peer lines
            VStack(alignment: .leading, spacing: 4) {
                Text("Peer (\(peerDeviceName)):")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(AgedManuscriptTheme.Colors.inkSecondary)
                
                ForEach(hunk.peerLines) { line in
                    HStack {
                        Text(line.isAddition ? "+ \(line.text)" : "  \(line.text)")
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(line.isAddition ? Color(hex: "#137333") : AgedManuscriptTheme.Colors.inkDark)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(line.isAddition ? Color(hex: "#E6F4EA") : Color(hex: "#FAF5E8"))
                            .cornerRadius(4)
                    }
                }
            }
            
            // Hunk Action Buttons
            HStack(spacing: 8) {
                Button(action: onPickLocal) {
                    Text("Keep Local")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(AgedManuscriptTheme.Colors.inkDark)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(AgedManuscriptTheme.Colors.parchment)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(AgedManuscriptTheme.Colors.parchmentBorder, lineWidth: 1)
                        )
                        .cornerRadius(6)
                }
                
                Button(action: onPickPeer) {
                    Text("Keep Peer")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(AgedManuscriptTheme.Colors.inkDark)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(AgedManuscriptTheme.Colors.parchment)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(AgedManuscriptTheme.Colors.parchmentBorder, lineWidth: 1)
                        )
                        .cornerRadius(6)
                }
                
                Button(action: onPickBoth) {
                    Text("Keep Both")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(AgedManuscriptTheme.Colors.inkDark)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(AgedManuscriptTheme.Colors.parchment)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(AgedManuscriptTheme.Colors.parchmentBorder, lineWidth: 1)
                        )
                        .cornerRadius(6)
                }
            }
        }
        .padding(12)
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(AgedManuscriptTheme.Colors.parchmentBorder, lineWidth: 1)
        )
        .cornerRadius(8)
    }
}

#Preview {
    HunkDiffView(
        hunk: ConflictHunk(
            lineRange: "Lines 14–22",
            title: "Strategic Goals",
            localLines: [ConflictHunkLine(text: "Target: Sept 15", isChange: true, isDeletion: true)],
            peerLines: [ConflictHunkLine(text: "Target: Oct 01", isChange: true, isAddition: true)]
        ),
        localDeviceName: "iPhone 15 Pro",
        peerDeviceName: "MacBook Pro",
        onPickLocal: {},
        onPickPeer: {},
        onPickBoth: {}
    )
    .padding()
    .background(AgedManuscriptTheme.Colors.parchment)
}
