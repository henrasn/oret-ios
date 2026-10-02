//
//  OnboardingScreen.swift
//  OretIOS
//
//  Root Onboarding Screen embedding OnboardingCarouselView
//

import SwiftUI

public struct OnboardingScreen: View {
    @State private var viewModel: OnboardingViewModel
    public let onComplete: () -> Void

    public init(
        viewModel: OnboardingViewModel = OnboardingViewModel(),
        onComplete: @escaping () -> Void
    ) {
        self._viewModel = State(initialValue: viewModel)
        self.onComplete = onComplete
    }

    public var body: some View {
        ZStack {
            AgedManuscriptTheme.Colors.parchment
                .ignoresSafeArea()

            OnboardingCarouselView(
                viewModel: viewModel,
                onFinish: onComplete
            )
        }
    }
}

#Preview {
    OnboardingScreen(onComplete: {})
}
