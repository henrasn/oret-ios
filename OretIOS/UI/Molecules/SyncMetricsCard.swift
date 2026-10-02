import SwiftUI

public struct SyncMetricsCard: View {
    public let summary: SyncSummaryReport
    
    public init(summary: SyncSummaryReport) {
        self.summary = summary
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Text("SUMMARY OF MERGED CHANGES")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(AgedManuscriptTheme.Colors.inkSecondary)
                    .tracking(0.5)
                Spacer()
                Image(systemName: "archivebox")
                    .font(.system(size: 13))
                    .foregroundColor(AgedManuscriptTheme.Colors.inkSecondary)
            }
            
            // 2x2 Grid
            VStack(spacing: 10) {
                HStack(spacing: 10) {
                    // Auto-Merged
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(summary.autoMergedCount) Auto-Merged")
                            .font(.system(size: 15, weight: .bold, design: .serif))
                            .foregroundColor(AgedManuscriptTheme.Colors.inkDark)
                        Text("Non-conflicting files")
                            .font(.system(size: 11))
                            .foregroundColor(AgedManuscriptTheme.Colors.inkSecondary)
                    }
                    .padding(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(hex: "#FAF5EA"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(hex: "#E8DDC5"), lineWidth: 1)
                    )
                    .cornerRadius(8)
                    
                    // Resolved
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(summary.resolvedConflictsCount) Resolved")
                            .font(.system(size: 15, weight: .bold, design: .serif))
                            .foregroundColor(AgedManuscriptTheme.Colors.inkDark)
                        Text("Manual decisions")
                            .font(.system(size: 11))
                            .foregroundColor(AgedManuscriptTheme.Colors.inkSecondary)
                    }
                    .padding(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(hex: "#FAF5EA"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(hex: "#E8DDC5"), lineWidth: 1)
                    )
                    .cornerRadius(8)
                }
                
                HStack(spacing: 10) {
                    // Added
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 14))
                            .foregroundColor(AgedManuscriptTheme.Colors.statusGreen)
                        Text("\(summary.addedCount) File Added")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(AgedManuscriptTheme.Colors.statusGreen)
                        Spacer()
                    }
                    .padding(10)
                    .frame(maxWidth: .infinity)
                    .background(Color(hex: "#FAF5EA"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(hex: "#E8DDC5"), lineWidth: 1)
                    )
                    .cornerRadius(8)
                    
                    // Unchanged
                    HStack {
                        Image(systemName: "checkmark.circle")
                            .font(.system(size: 14))
                            .foregroundColor(AgedManuscriptTheme.Colors.inkSecondary)
                        Text("\(summary.unchangedCount) Unchanged")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(AgedManuscriptTheme.Colors.inkSecondary)
                        Spacer()
                    }
                    .padding(10)
                    .frame(maxWidth: .infinity)
                    .background(Color(hex: "#FAF5EA"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(hex: "#E8DDC5"), lineWidth: 1)
                    )
                    .cornerRadius(8)
                }
            }
            
            Divider()
                .padding(.vertical, 4)
            
            // Meta Row
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: "point.bottomleft.forward.to.point.topright.scurve")
                        .font(.system(size: 10))
                        .foregroundColor(AgedManuscriptTheme.Colors.inkSecondary)
                    Text("rev: \(summary.revisionId)")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(AgedManuscriptTheme.Colors.inkSecondary)
                }
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(Color(hex: "#ECE4CF"))
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color(hex: "#DFD5BC"), lineWidth: 1)
                )
                .cornerRadius(4)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: "lock.open.fill")
                        .font(.system(size: 10))
                        .foregroundColor(AgedManuscriptTheme.Colors.statusGreen)
                    Text("Read-Write Mode Restored")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(AgedManuscriptTheme.Colors.statusGreen)
                }
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(Color(hex: "#EAF4EA"))
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color(hex: "#CBE4CB"), lineWidth: 1)
                )
                .cornerRadius(4)
            }
        }
        .padding(16)
        .background(AgedManuscriptTheme.Colors.parchmentCard)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(AgedManuscriptTheme.Colors.parchmentBorder, lineWidth: 1)
        )
        .cornerRadius(12)
    }
}

#Preview {
    SyncMetricsCard(summary: SyncSummaryReport())
        .padding()
        .background(AgedManuscriptTheme.Colors.parchment)
}
