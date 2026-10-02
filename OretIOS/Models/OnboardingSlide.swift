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

    /// Canonical slides matching Stitch specifications
    public static let canonicalSlides: [OnboardingSlide] = [
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
