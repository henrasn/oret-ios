//
//  OnboardingCarouselView.swift
//  OretIOS
//
//  Onboarding Carousel Organism with Aged Manuscript Styling
//

import SwiftUI
import Observation

public struct OnboardingCarouselView: View {
    public var viewModel: OnboardingViewModel
    public let onFinish: () -> Void

    public init(
        viewModel: OnboardingViewModel,
        onFinish: @escaping () -> Void
    ) {
        self.viewModel = viewModel
        self.onFinish = onFinish
    }

    public var body: some View {
        @Bindable var viewModel = viewModel
        VStack(spacing: 0) {
            // MARK: - Top Navigation Bar (Skip Action)
            HStack {
                Spacer()
                if !viewModel.isLastSlide {
                    SkipButton {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            viewModel.skipOnboarding()
                        }
                    }
                } else {
                    // Invisible placeholder to keep header height consistent
                    Text("Skip")
                        .font(AgedManuscriptTheme.Fonts.sansBody(size: 15, weight: .medium))
                        .foregroundColor(.clear)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                }
            }
            .frame(height: 44)
            .padding(.horizontal, 20)
            .padding(.top, 8)

            // MARK: - Swipable Slides Carousel
            TabView(selection: $viewModel.currentSlideIndex) {
                ForEach(viewModel.slides.indices, id: \.self) { index in
                    OnboardingSlideCard(slide: viewModel.slides[index])
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .animation(.easeInOut(duration: 0.3), value: viewModel.currentSlideIndex)

            // MARK: - Bottom Controls Section
            VStack(spacing: 24) {
                // Pagination Dots
                PageDots(
                    numberOfPages: viewModel.slides.count,
                    currentPage: viewModel.currentSlideIndex
                )

                // Navigation Buttons Row
                if viewModel.isFirstSlide {
                    // Slide 1: Full-width Next Button
                    PrimaryButton(title: "Next") {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            viewModel.nextSlide()
                        }
                    }
                } else if viewModel.isLastSlide {
                    // Slide 3: Back + Get Started
                    HStack(spacing: 12) {
                        PrimaryButton(
                            title: "Back",
                            variant: .secondary
                        ) {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                viewModel.previousSlide()
                            }
                        }

                        PrimaryButton(title: "Get Started") {
                            viewModel.completeOnboarding()
                            onFinish()
                        }
                    }
                } else {
                    // Slide 2: Back + Next
                    HStack(spacing: 12) {
                        PrimaryButton(
                            title: "Back",
                            variant: .secondary
                        ) {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                viewModel.previousSlide()
                            }
                        }

                        PrimaryButton(title: "Next") {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                viewModel.nextSlide()
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .agedManuscriptBackground()
    }
}

#Preview {
    OnboardingCarouselView(
        viewModel: OnboardingViewModel(),
        onFinish: {}
    )
}
