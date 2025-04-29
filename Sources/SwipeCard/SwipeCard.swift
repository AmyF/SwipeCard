//
//  SwipeCard.swift
//  G001UI
//
//  Created by unko on 2025/4/27.
//

import SwiftUI

public struct SwipeCard<Content: View>: View {
    private let configuration: SwipeConfiguration
    private let content: Content
    @StateObject private var gestureHandler: SwipeGestureHandler
    @State private var isInteractionEnabled = true

    private let onBegin: ((SwipeDirection, CGFloat) -> Void)?
    private let onCancel: (() -> Void)?
    private let onComplete: ((SwipeDirection) -> Bool)?
    private let onFinish: ((SwipeDirection) -> Void)?

    init(
        configuration: SwipeConfiguration,
        onBegin: ((SwipeDirection, CGFloat) -> Void)? = nil,
        onCancel: (() -> Void)? = nil,
        onComplete: ((SwipeDirection) -> Bool)? = nil,
        onFinish: ((SwipeDirection) -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.configuration = configuration
        self.content = content()
        self.onBegin = onBegin
        self.onCancel = onCancel
        self.onComplete = onComplete
        self.onFinish = onFinish
        self._gestureHandler = StateObject(
            wrappedValue: SwipeGestureHandler(configuration: configuration)
        )
    }

    public var body: some View {
        content
            .offset(gestureHandler.offset)
            .scaleEffect(gestureHandler.scaleEffect)
            .opacity(gestureHandler.opacity)
            .rotationEffect(.degrees(Double(gestureHandler.offset.width / 25)), anchor: gestureHandler.rotationAnchor)
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        guard isInteractionEnabled else { return }
                        gestureHandler.handleDrag(gesture)
                        onBegin?(
                            gestureHandler.activeDirection ?? .right,
                            gestureHandler.swipeProgress
                        )
                    }
                    .onEnded { _ in
                        guard isInteractionEnabled else { return }
                        handleSwipeCompletion()
                    }
            )
            .animation(
                configuration.animationConfig.interactive, value: gestureHandler.offset
            )
            .sensoryFeedback(
                .selection, trigger: gestureHandler.swipeProgress >= 0.5
            ) { old, new in
                if case .disabled = configuration.hapticStyle { return false }
                return new
            }
            .sensoryFeedback(
                configuration.hapticStyle.feedbackType, trigger: gestureHandler.swipeProgress >= 1.0
            ) { old, new in
                if case .disabled = configuration.hapticStyle { return false }
                return new
            }
    }

    private func handleSwipeCompletion() {
        if gestureHandler.swipeProgress >= 1.0 {
            isInteractionEnabled = false
            let finalDirection = gestureHandler.activeDirection ?? .right
            let shouldComplete = onComplete?(finalDirection) ?? true
            if shouldComplete {
                withAnimation(configuration.animationConfig.exit) {
                    gestureHandler.offset = CGSize(
                        width: gestureHandler.activeDirection?.isHorizontal ?? true
                            ? (gestureHandler.activeDirection == .right ? 1000 : -1000) : 0,
                        height: gestureHandler.activeDirection?.isVertical ?? true
                            ? (gestureHandler.activeDirection == .down ? 1000 : -1000) : 0
                    )
                } completion: {
                    onFinish?(finalDirection)
                }
            } else {
                resetCardPosition()
            }
            isInteractionEnabled = true
        } else {
            resetCardPosition()
            onCancel?()
        }
    }

    private func resetCardPosition() {
        withAnimation(configuration.animationConfig.interactive) {
            gestureHandler.resetState()
        }
    }
}
