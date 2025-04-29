//
//  SwipeGestureHandler.swift
//  G001UI
//
//  Created by unko on 2025/4/27.
//

import SwiftUI

@MainActor
final class SwipeGestureHandler: ObservableObject {
    @Published var offset: CGSize = .zero
    @Published var activeDirection: SwipeDirection?
    @Published var swipeProgress: CGFloat = 0.0
    
    var rotationAnchor: UnitPoint {
        switch activeDirection {
        case .left: return .topLeading
        case .right: return .topTrailing
        default: return .center
        }
    }
    
    var scaleEffect: CGFloat {
        1 + 0.02 * swipeProgress
    }
    
    var opacity: CGFloat {
        1 - 0.2 * swipeProgress
    }

    private let configuration: SwipeConfiguration

    init(configuration: SwipeConfiguration) {
        self.configuration = configuration
    }

    func handleDrag(_ gesture: DragGesture.Value) {
        offset = gesture.translation
        swipeProgress = calculateProgress()
        activeDirection = calculateDirection()
    }

    private func calculateProgress() -> CGFloat {
        let horizontalProgress = configuration.supportDirection.contains(.horizontal) ? abs(offset.width) : 0
        let verticalProgress = configuration.supportDirection.contains(.vertical) ? abs(offset.height) : 0
        let maxOffset = max(horizontalProgress, verticalProgress)
        return min(maxOffset / configuration.threshold, 1.0)
    }

    private func calculateDirection() -> SwipeDirection? {
        guard swipeProgress >= 0.3 else { return nil }
        
        let horizontalAllowed = configuration.supportDirection.contains(.horizontal)
        let verticalAllowed = configuration.supportDirection.contains(.vertical)
        
        if horizontalAllowed && !verticalAllowed {
            return offset.width > 0 ? .right : .left
        } else if verticalAllowed && !horizontalAllowed {
            return offset.height > 0 ? .down : .up
        }
        
        let isHorizontal = abs(offset.width) > abs(offset.height)

        if isHorizontal {
            return offset.width > 0 ? .right : .left
        } else {
            return offset.height > 0 ? .down : .up
        }
    }

    func resetState() {
        offset = .zero
        activeDirection = nil
        swipeProgress = 0.0
    }
}
