import SwiftUI

public struct SyncFinishedSummaryScreen: View {
    public let summary: SyncSummaryReport
    public var onDone: () -> Void
    
    public init(
        summary: SyncSummaryReport = SyncSummaryReport(),
        onDone: @escaping () -> Void = {}
    ) {
        self.summary = summary
        self.onDone = onDone
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Top Bar
            HStack {
                Text("Sync Complete")
                    .font(.system(size: 18, weight: .bold, design: .serif))
                    .foregroundColor(AgedManuscriptTheme.Colors.inkDark)
                
                Spacer()
                
                Text("Consensus")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(AgedManuscriptTheme.Colors.statusGreen)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color(hex: "#E8F5E9"))
                    .cornerRadius(4)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(AgedManuscriptTheme.Colors.parchment)
            .overlay(
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(AgedManuscriptTheme.Colors.parchmentBorder),
                alignment: .bottom
            )
            
            // Scrollable Body
            ScrollView {
                VStack(spacing: 16) {
                    Spacer().frame(height: 16)
                    
                    // Success Circle
                    ZStack {
                        Circle()
                            .fill(Color(hex: "#E8F5E9"))
                            .frame(width: 64, height: 64)
                            .overlay(
                                Circle().stroke(Color(hex: "#A5D6A7"), lineWidth: 1.5)
                            )
                        
                        Image(systemName: "checkmark")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(AgedManuscriptTheme.Colors.statusGreen)
                    }
                    
                    Text("Sync Finished Successfully!")
                        .font(.system(size: 22, weight: .bold, design: .serif))
                        .foregroundColor(AgedManuscriptTheme.Colors.inkDark)
                        .multilineTextAlignment(.center)
                    
                    Text("All changes between this workstation and \(summary.peerDeviceName) have been reconciled and committed.")
                        .font(.system(size: 13))
                        .foregroundColor(AgedManuscriptTheme.Colors.inkSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 8)
                    
                    // Metrics Card
                    SyncMetricsCard(summary: summary)
                    
                    Spacer().frame(height: 24)
                }
                .padding(20)
            }
            
            // Bottom Action
            VStack {
                Button(action: onDone) {
                    HStack(spacing: 8) {
                        Text("Done & Return to Notes")
                            .font(.system(size: 15, weight: .bold))
                        Image(systemName: "arrow.right")
                            .font(.system(size: 14, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(AgedManuscriptTheme.Colors.inkDark)
                    .cornerRadius(8)
                }
            }
            .padding(16)
            .background(AgedManuscriptTheme.Colors.parchment)
            .overlay(
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(AgedManuscriptTheme.Colors.parchmentBorder),
                alignment: .top
            )
        }
        .background(AgedManuscriptTheme.Colors.parchment)
    }
}

#Preview {
    SyncFinishedSummaryScreen()
}
