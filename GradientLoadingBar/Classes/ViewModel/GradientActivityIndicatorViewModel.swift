//
//  GradientActivityIndicatorViewModel.swift
//  GradientLoadingBar
//
//  Created by Felix Mau on 08/26/19.
//  Copyright © 2019 Felix Mau. All rights reserved.
//

import Foundation
import LightweightObservable

/// This view model contains all logic related to the `GradientActivityIndicatorView`.
final class GradientActivityIndicatorViewModel {
    // MARK: - Types

    /// State of the progress animation.
    enum ProgressAnimationState: Equatable {
        /// The progress animation is currently stopped.
        case none

        /// The progress animation is currently running with the given duration.
        case animating(duration: TimeInterval)
    }

    // MARK: - Public properties

    /// Observable state of the progress animation.
    var progressAnimationState: Observable<ProgressAnimationState> {
        return progressAnimationStateSubject.asObservable
    }

    ///
    var gradientLayerColors: Observable<[CGColor]> {
        return gradientLayerColorsSubject.asObservable
    }

    ///
    var isHidden = false {
        didSet {
            if isHidden {
                progressAnimationStateSubject.value = .none
            } else {
                progressAnimationStateSubject.value = .animating(duration: progressAnimationDuration)
            }
        }
    }

    /// Colors used for the gradient.
    var gradientColors = UIColor.GradientLoadingBar.gradientColors {
        didSet {
            gradientLayerColorsSubject.value = makeGradientLayerColors()
        }
    }

    /// Duration for the progress animation.
    var progressAnimationDuration = TimeInterval.GradientLoadingBar.progressDuration

    // MARK: - Private properties

    private let progressAnimationStateSubject: Variable<ProgressAnimationState>

    private let gradientLayerColorsSubject: Variable<[CGColor]>

    // MARK: - Initializer

    init() {
        // As the view is visible initially, we need to set-up the observables accordingly.
        progressAnimationStateSubject = Variable(.animating(duration: progressAnimationDuration))

        // Small workaround as calls to `self.makeGradientLayerColors()` aren't allowed before all properties have been initialized.
        gradientLayerColorsSubject = Variable([])
        gradientLayerColorsSubject.value = makeGradientLayerColors()
    }

    // MARK: - Private methods

    /// Simulate infinte animation - Therefore we'll reverse the colors and remove the first and last item
    /// to prevent duplicate values at the "inner edges" destroying the infinite look.
    private func makeGradientLayerColors() -> [CGColor] {
        let reversedColors = gradientColors
            .reversed()
            .dropFirst()
            .dropLast()

        let infiniteGradientColors = gradientColors + reversedColors + gradientColors
        return infiniteGradientColors.map { $0.cgColor }
    }
}
