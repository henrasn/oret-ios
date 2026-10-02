//
//  OnboardingSlide.swift
//  OretIOS
//
//  Data model for Onboarding Slides
//

import Foundation

#if canImport(SharedLogic)
import SharedLogic
#endif

public enum OnboardingIllustrationType: String, CaseIterable, Identifiable {
    case localStorage
    case directSync
    case intelligentReconciliation

    public var id: String { rawValue }
}

public struct OnboardingSlide: Identifiable, Equatable {
    public let id: Int
    public let title: String
    public let description: String
    public let illustrationType: OnboardingIllustrationType

    public init(
        id: Int,
        title: String,
        description: String,
        illustrationType: OnboardingIllustrationType
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.illustrationType = illustrationType
    }

    #if canImport(SharedLogic)
    /// Direct bridge initializer consuming exported KMP OnboardingSlideModel
    public init(kmpModel: OnboardingSlideModel) {
        let type: OnboardingIllustrationType
        switch kmpModel.id {
        case 1: type = .localStorage
        case 2: type = .directSync
        case 3: type = .intelligentReconciliation
        default: type = .localStorage
        }
        self.init(
            id: Int(kmpModel.id),
            title: kmpModel.title,
            description: kmpModel.description,
            illustrationType: type
        )
    }

    /// Maps exported KMP slide models into native UI slides
    public static func fromKmpSlides(_ kmpSlides: [OnboardingSlideModel]) -> [OnboardingSlide] {
        return kmpSlides.map { OnboardingSlide(kmpModel: $0) }
    }
    #endif

    /// Canonical slides matching Stitch specifications & KMP definitions
    public static var canonicalSlides: [OnboardingSlide] {
        #if canImport(SharedLogic)
        return fromKmpSlides(OnboardingContent.shared.slides)
        #else
        return fallbackSlides
        #endif
    }

    /// Fallback slides used when SharedLogic framework is not loaded
    public static let fallbackSlides: [OnboardingSlide] = [
        OnboardingSlide(
            id = 1,
            title: "Your Notes, Stored Locally",
            description: "Everything you write lives directly on your device. Fast, offline-first, and completely private with no external servers.",
            illustrationType: .localStorage
        ),
        OnboardingSlide(
            id = 2,
            title: "Direct Device-to-Device Sync",
            description: "Synchronize your notes directly between your phone and computer over your local network. No cloud middlemen, fully end-to-end encrypted.",
            illustrationType: .directSync
        ),
        OnboardingSlide(
            id = 3,
            title: "Intelligent Reconciliation",
            description: "Edit seamlessly across devices. Non-conflicting changes merge automatically, and safe controls ensure you never lose a word.",
            illustrationType: .intelligentReconciliation
        )
    ]
}
