import SwiftUI

public struct OfflineNoticeBannerView: View {
    public let peerDeviceName: String
    
    public init(peerDeviceName: String) {
        self.peerDeviceName = peerDeviceName
    }
    
    public var body: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Peer Disconnected — Safe to Continue Offline")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(Color(hex: "#78350F"))
                
                Text("Take your time reviewing. Decisions will be saved locally and delivered to \(peerDeviceName) upon reconnection.")
                    .font(.system(size: 11))
                    .foregroundColor(AgedManuscriptTheme.Colors.amberWindowText)
                    .lineLimit(2)
            }
            
            Spacer()
            
            Text("OFFLINE")
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundColor(Color(hex: "#78350F"))
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(AgedManuscriptTheme.Colors.amberWindowBorder)
                .cornerRadius(4)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(AgedManuscriptTheme.Colors.amberWindowBg)
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(AgedManuscriptTheme.Colors.amberWindowBorder),
            alignment: .bottom
        )
    }
}

#Preview {
    OfflineNoticeBannerView(peerDeviceName: "MacBook Pro")
}
