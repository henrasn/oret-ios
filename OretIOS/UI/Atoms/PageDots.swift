//
//  PageDots.swift
//  OretIOS
//
//  Pagination Dot Indicators Atom
//

import SwiftUI

public struct PageDots: View {
    public let numberOfPages: Int
    public let currentPage: Int

    public init(numberOfPages: Int = 3, currentPage: Int) {
        self.numberOfPages = numberOfPages
        self.currentPage = currentPage
    }

    public var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<numberOfPages, id: \.self) { index in
                if index == currentPage {
                    // Active indicator: elongated ink bar #171818
                    Capsule()
                        .fill(AgedManuscriptTheme.Colors.inkDark)
                        .frame(width: 28, height: 8)
                        .transition(.scale)
                } else {
                    // Inactive indicator: subtle dot with parchment border #E6D9BC
                    Circle()
                        .stroke(AgedManuscriptTheme.Colors.parchmentBorder, lineWidth: 1.2)
                        .background(
                            Circle()
                                .fill(AgedManuscriptTheme.Colors.parchmentBorder.opacity(0.3))
                        )
                        .frame(width: 8, height: 8)
                }
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.7), value: currentPage)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("Page \(currentPage + 1) of \(numberOfPages)"))
    }
}

#Preview {
    VStack(spacing: 24) {
        PageDots(numberOfPages: 3, currentPage: 0)
        PageDots(numberOfPages: 3, currentPage: 1)
        PageDots(numberOfPages: 3, currentPage: 2)
    }
    .padding()
    .agedManuscriptBackground()
}
