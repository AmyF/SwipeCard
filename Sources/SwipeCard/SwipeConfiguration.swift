//
//  SwipeConfiguration.swift
//  G001UI
//
//  Created by unko on 2025/4/27.
//

import SwiftUI

public enum SwipeDirection: Sendable {
    case left
    case right
    case up
    case down
}

public struct SwipeSupportDirection: Sendable, OptionSet {
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    public static let horizontal = SwipeSupportDirection(rawValue: 1 << 0)
    public static let vertical = SwipeSupportDirection(rawValue: 1 << 1)
    
    public static let all: SwipeSupportDirection = [.horizontal, vertical]
}

public struct SwipeConfiguration: Sendable {
    public enum HapticStyle: Sendable {
        case disabled
        case basic
        case enhanced(SensoryFeedback)

        var feedbackType: SensoryFeedback {
            switch self {
            case .enhanced(let type):
                return type
            default:
                return .success
            }
        }
    }

    public struct AnimationConfig: Sendable {
        public enum CurveType: Sendable {
            case spring(damping: CGFloat, response: CGFloat)
            case easeInOut(duration: CGFloat)
            case custom(Animation)

            var value: Animation {
                switch self {
                case .spring(let damping, let response):
                    return .spring(response: response, dampingFraction: damping)
                case .easeInOut(let duration):
                    return .easeInOut(duration: duration)
                case .custom(let animation):
                    return animation
                }
            }
        }

        public var exit: Animation
        public var interactive: Animation
        public var entryDelay: Double

        public init(
            exit: CurveType = .easeInOut(duration: 0.4),
            interactive: CurveType = .custom(.interactiveSpring(response: 0.3)),
            entryDelay: Double = 0.1
        ) {
            self.exit = exit.value
            self.interactive = interactive.value
            self.entryDelay = entryDelay
        }
    }

    public let threshold: CGFloat
    public let animationConfig: AnimationConfig
    public let hapticStyle: HapticStyle
    public let supportDirection: SwipeSupportDirection

    public init(
        threshold: CGFloat = 120,
        animationConfig: AnimationConfig = AnimationConfig(),
        hapticStyle: HapticStyle = .basic,
        supportDirection: SwipeSupportDirection = .horizontal,
    ) {
        self.threshold = threshold
        self.animationConfig = animationConfig
        self.hapticStyle = hapticStyle
        self.supportDirection = supportDirection
    }

    public static let `default` = SwipeConfiguration()
}
