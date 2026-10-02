//
//  OnboardingViewModel.swift
//  OretIOS
//
//  ViewModel for Onboarding Carousel State & Navigation
//

import Foundation
import Observation

#if canImport(SharedLogic)
import SharedLogic
#endif

@Observable
public final class OnboardingViewModel {
    public var currentSlideIndex: Int = 0
    public var hasCompletedOnboarding: Bool = false
    public let slides: [OnboardingSlide]

    public init(slides: [OnboardingSlide] = OnboardingSlide.canonicalSlides) {
        self.slides = slides
        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    }

    #if canImport(SharedLogic)
    /// Direct consumption of KMP exported OnboardingSlideModel collection
    public convenience init(kmpSlides: [OnboardingSlideModel]) {
        self.init(slides: OnboardingSlide.fromKmpSlides(kmpSlides))
    }
    #endif

    public var isFirstSlide: Bool {
        currentSlideIndex == 0
    }

    public var isLastSlide: Bool {
        currentSlideIndex >= slides.count - 1
    }

    public var currentSlide: OnboardingSlide {
        slides[min(max(currentSlideIndex, 0), slides.count - 1)]
    }

    public func nextSlide() {
        if currentSlideIndex < slides.count - 1 {
            currentSlideIndex += 1
        }
    }

    public func previousSlide() {
        if currentSlideIndex > 0 {
            currentSlideIndex -= 1
        }
    }

    public func skipOnboarding() {
        currentSlideIndex = slides.count - 1
    }

    public func completeOnboarding() {
        hasCompletedOnboarding = true
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
    }
}
