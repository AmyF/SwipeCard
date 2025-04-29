//
//  SwipeCardDelegate.swift
//  G001UI
//
//  Created by unko on 2025/4/27.
//

import Foundation

@MainActor
public protocol SwipeCardDelegate: AnyObject {
    func didBeginSwiping(direction: SwipeDirection, progress: CGFloat)
    func didCancelSwipe()
    func didCompleteSwipe(direction: SwipeDirection) -> Bool
    func didFinishSwipe()
}

extension SwipeDirection {
    public var isHorizontal: Bool {
        self == .left || self == .right
    }

    public var isVertical: Bool {
        self == .up || self == .down
    }
}
