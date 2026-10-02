import SwiftUI

public struct NonResolverWaitingScreen: View {
    public let peerDeviceName: String
    public var onAbort: () -> Void
    
    public init(
        peerDeviceName: String = "MacBook Pro",
        onAbort: @escaping () -> Void = {}
    ) {
        self.peerDeviceName = peerDeviceName
        self.onAbort = onAbort
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Top Bar
            HStack {
                Button(action: onAbort) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(AgedManuscriptTheme.Colors.inkDark)
                }
                
                Spacer()
                
                Text("Sync in Progress")
                    .font(.system(size: 18, weight: .bold, design: .serif))
                    .foregroundColor(AgedManuscriptTheme.Colors.inkDark)
                
                Spacer()
                
                Text("Passive")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(AgedManuscriptTheme.Colors.inkSecondary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(AgedManuscriptTheme.Colors.parchmentField)
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
            
            // Lock Banner
            HStack(spacing: 8) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 12))
                    .foregroundColor(AgedManuscriptTheme.Colors.amberWindowText)
                
                Text("Workspace Locked (Strict Read-Only Mode active)")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(AgedManuscriptTheme.Colors.amberWindowText)
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(AgedManuscriptTheme.Colors.amberWindowBg)
            .overlay(
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(AgedManuscriptTheme.Colors.amberWindowBorder),
                alignment: .bottom
            )
            
            // Center Content
            VStack(spacing: 16) {
                Spacer()
                
                ZStack {
                    Circle()
                        .stroke(AgedManuscriptTheme.Colors.parchmentBorder, lineWidth: 1)
                        .background(Circle().fill(AgedManuscriptTheme.Colors.parchmentField))
                        .frame(width: 80, height: 80)
                    
                    ProgressView()
                        .scaleEffect(1.4)
                        .tint(AgedManuscriptTheme.Colors.inkDark)
                }
                
                Text("Synchronization in Progress")
                    .font(.system(size: 20, weight: .bold, design: .serif))
                    .foregroundColor(AgedManuscriptTheme.Colors.inkDark)
                
                Text("Waiting for \(peerDeviceName) to finish 3-way reconciliation and resolve file conflicts.")
                    .font(.system(size: 14))
                    .foregroundColor(AgedManuscriptTheme.Colors.inkSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                
                // Status Card
                VStack(spacing: 10) {
                    HStack {
                        Text("Status:")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(AgedManuscriptTheme.Colors.inkDark)
                        Spacer()
                        Text("Awaiting FinalResolvedState")
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .foregroundColor(AgedManuscriptTheme.Colors.amberWindowText)
                    }
                    
                    HStack {
                        Text("Designated Resolver:")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(AgedManuscriptTheme.Colors.inkDark)
                        Spacer()
                        Text(peerDeviceName)
                            .font(.system(size: 12))
                            .foregroundColor(AgedManuscriptTheme.Colors.inkSecondary)
                    }
                    
                    HStack {
                        Text("Local Action Required:")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(AgedManuscriptTheme.Colors.inkDark)
                        Spacer()
                        Text("None (Automatic Merge)")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(AgedManuscriptTheme.Colors.statusGreen)
                    }
                }
                .padding(16)
                .background(AgedManuscriptTheme.Colors.parchmentCard)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(AgedManuscriptTheme.Colors.parchmentBorder, lineWidth: 1)
                )
                .cornerRadius(12)
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Abort Button
                Button(action: onAbort) {
                    Text("Abort Session")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(AgedManuscriptTheme.Colors.errorRed)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 10)
                        .background(AgedManuscriptTheme.Colors.errorContainer)
                        .cornerRadius(8)
                }
                .padding(.bottom, 24)
            }
        }
        .background(AgedManuscriptTheme.Colors.parchment)
    }
}

#Preview {
    NonResolverWaitingScreen()
}
